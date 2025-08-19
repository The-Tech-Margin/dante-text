-- Performance optimization functions for Dante Database Frontend
-- These functions enable fast, dynamic queries for all analytical perspectives

-- Performance functions use the actual schema types and column names

-- 1. FAST COMMENTARY SEARCH WITH RANKING
CREATE OR REPLACE FUNCTION search_commentaries_ranked(
  search_term TEXT,
  lang_filter TEXT DEFAULT NULL,
  limit_count INT DEFAULT 20
)
RETURNS TABLE (
  id UUID,
  original_id VARCHAR(5),
  name VARCHAR(50),
  author TEXT,
  language language_type,
  pub_year VARCHAR(20),
  excerpt TEXT,
  rank REAL
) 
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.comm_id,
    c.comm_name,
    c.comm_author,
    c.comm_lang,
    c.comm_pub_year,
    LEFT(c.comm_biblio, 200) as excerpt,
    ts_rank(
      to_tsvector('simple', c.comm_author || ' ' || c.comm_biblio || ' ' || c.comm_name),
      plainto_tsquery('simple', search_term)
    ) as rank
  FROM dde_commentaries c
  WHERE 
    (lang_filter IS NULL OR c.comm_lang = lang_filter::language_type) AND
    (
      to_tsvector('simple', c.comm_author || ' ' || c.comm_biblio || ' ' || c.comm_name) 
      @@ plainto_tsquery('simple', search_term)
    )
  ORDER BY rank DESC, c.comm_name
  LIMIT limit_count;
END;
$$;

-- 2. FAST TEXT SEARCH WITH CONTEXT
CREATE OR REPLACE FUNCTION search_texts_with_context(
  search_term TEXT,
  commentary_ids UUID[] DEFAULT NULL,
  cantica_filter cantica_type DEFAULT NULL,
  limit_count INT DEFAULT 50
)
RETURNS TABLE (
  id UUID,
  doc_id VARCHAR(12),
  commentary_name VARCHAR(50),
  cantica dante_cantica,
  canto_id INTEGER,
  start_line INTEGER,
  end_line INTEGER,
  text_excerpt TEXT,
  rank REAL
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    t.id,
    t.doc_id,
    c.name as commentary_name,
    t.cantica,
    t.canto_id,
    t.start_line,
    t.end_line,
    LEFT(t.content, 300) as text_excerpt,
    ts_rank(t.text_search, plainto_tsquery('simple', search_term)) as rank
  FROM dde_texts t
  JOIN dde_commentaries c ON t.commentary_id = c.id
  WHERE 
    (commentary_ids IS NULL OR t.commentary_id = ANY(commentary_ids)) AND
    (cantica_filter IS NULL OR t.cantica = cantica_filter) AND
    t.text_search @@ plainto_tsquery('simple', search_term)
  ORDER BY rank DESC, t.doc_id
  LIMIT limit_count;
END;
$$;

-- 3. COMMENTARY STATISTICS FOR DASHBOARD
CREATE OR REPLACE FUNCTION get_commentary_stats(commentary_id UUID)
RETURNS TABLE (
  total_texts INTEGER,
  canticas_covered INTEGER,
  cantos_covered INTEGER,
  lines_covered INTEGER,
  languages_used language_type[],
  text_types_used text_type[],
  avg_text_length INTEGER,
  last_updated TIMESTAMPTZ
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*)::INTEGER as total_texts,
    COUNT(DISTINCT t.cantica)::INTEGER as canticas_covered,
    COUNT(DISTINCT t.canto_id)::INTEGER as cantos_covered,
    (MAX(t.end_line) - MIN(t.start_line) + 1)::INTEGER as lines_covered,
    ARRAY_AGG(DISTINCT t.text_language) as languages_used,
    ARRAY_AGG(DISTINCT t.text_type) as text_types_used,
    AVG(LENGTH(t.content))::INTEGER as avg_text_length,
    MAX(t.updated_at) as last_updated
  FROM dde_texts t
  WHERE t.commentary_id = get_commentary_stats.commentary_id;
END;
$$;

-- 4. CROSS-COMMENTARY ANALYSIS
CREATE OR REPLACE FUNCTION compare_commentaries_by_passage(
  cantica_param cantica_type,
  canto_param INTEGER,
  start_line_param INTEGER,
  end_line_param INTEGER
)
RETURNS TABLE (
  commentary_id UUID,
  commentary_name VARCHAR(50),
  author TEXT,
  language language_type,
  text_excerpt TEXT,
  coverage_score REAL
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id as commentary_id,
    c.comm_name as commentary_name,
    c.comm_author,
    c.comm_lang,
    LEFT(t.content, 500) as text_excerpt,
    (
      LEAST(t.end_line, end_line_param) - GREATEST(t.start_line, start_line_param) + 1
    )::REAL / (end_line_param - start_line_param + 1) as coverage_score
  FROM dde_texts t
  JOIN dde_commentaries c ON t.commentary_id = c.id
  WHERE 
    t.cantica = cantica_param AND
    t.canto_id = canto_param AND
    t.start_line <= end_line_param AND
    t.end_line >= start_line_param
  ORDER BY coverage_score DESC, c.comm_name;
END;
$$;

-- 5. NAVIGATION TREE FOR HIERARCHICAL BROWSING
CREATE OR REPLACE FUNCTION get_navigation_tree(commentary_id UUID DEFAULT NULL)
RETURNS TABLE (
  cantica dante_cantica,
  canto_id INTEGER,
  text_count INTEGER,
  line_range TEXT,
  has_texts BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    t.cantica,
    t.canto_id,
    COUNT(*)::INTEGER as text_count,
    MIN(t.start_line)::TEXT || '-' || MAX(t.end_line)::TEXT as line_range,
    COUNT(*) > 0 as has_texts
  FROM dde_texts t
  WHERE (commentary_id IS NULL OR t.commentary_id = get_navigation_tree.commentary_id)
  GROUP BY t.cantica, t.canto_id
  ORDER BY t.cantica, t.canto_id;
END;
$$;

-- 6. FULL-TEXT SEARCH WITH HIGHLIGHTING (for modern search UX)
CREATE OR REPLACE FUNCTION search_with_highlights(
  search_term TEXT,
  commentary_filter UUID DEFAULT NULL,
  limit_count INT DEFAULT 20
)
RETURNS TABLE (
  id UUID,
  doc_id VARCHAR(12),
  commentary_name VARCHAR(50),
  cantica dante_cantica,
  canto_id INTEGER,
  highlighted_text TEXT,
  rank REAL
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    t.id,
    t.doc_id,
    c.name as commentary_name,
    t.cantica,
    t.canto_id,
    ts_headline(
      to_tsvector('simple', t.content) @@ plainto_tsquery('simple', search_term),
      'MaxWords=50, MinWords=10, StartSel=<mark>, StopSel=</mark>'
    ) as highlighted_text,
    ts_rank(t.text_search, plainto_tsquery('simple', search_term)) as rank
  FROM dde_texts t
  JOIN dde_commentaries c ON t.commentary_id = c.id
  WHERE 
    (commentary_filter IS NULL OR t.commentary_id = commentary_filter) AND
    t.text_search @@ plainto_tsquery('simple', search_term)
  ORDER BY rank DESC
  LIMIT limit_count;
END;
$$;

-- 7. PERFORMANCE INDEXES FOR FAST QUERIES
CREATE INDEX IF NOT EXISTS idx_texts_cantica_canto 
ON dde_texts (cantica, canto_id);

CREATE INDEX IF NOT EXISTS idx_texts_line_range 
ON dde_texts (start_line, end_line);

CREATE INDEX IF NOT EXISTS idx_texts_composite_navigation 
ON dde_texts (commentary_id, cantica, canto_id, start_line);

CREATE INDEX IF NOT EXISTS idx_commentaries_language_year 
ON dde_commentaries (comm_lang, comm_pub_year);

-- Grant permissions for web app access
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;
