-- Fix UNION ORDER BY syntax error and embedded resource issues

-- 1. Fix alex_scholarly_search_all_versions UNION syntax
CREATE OR REPLACE FUNCTION alex_scholarly_search_all_versions(
  search_term TEXT,
  include_historical BOOLEAN DEFAULT true,
  version_filter version_source DEFAULT NULL,
  result_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
  commentary_name VARCHAR(64),
  version_source version_source,
  cantica cantica_type,
  canto_id INTEGER,
  content_match TEXT,
  is_historical BOOLEAN,
  relevance_score REAL
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  -- Current texts search
  SELECT 
    c.comm_name,
    'current_2024'::version_source,
    t.cantica,
    t.canto_id,
    LEFT(t.content, 200) as content_match,
    false as is_historical,
    ts_rank(to_tsvector('simple', t.content), plainto_tsquery('simple', search_term)) as relevance_score
  FROM dde_texts t
  JOIN dde_commentaries c ON t.commentary_id = c.id
  WHERE to_tsvector('simple', t.content) @@ plainto_tsquery('simple', search_term)
  AND (version_filter IS NULL OR version_filter = 'current_2024')
  
  UNION ALL
  
  -- Historical texts search (if enabled)
  SELECT 
    th.commentary_name,
    COALESCE(th.version_source, 'alexandria_archive'::version_source),
    th.cantica,
    th.canto_id,
    LEFT(th.content, 200) as content_match,
    true as is_historical,
    ts_rank(to_tsvector('simple', th.content), plainto_tsquery('simple', search_term)) as relevance_score
  FROM alex_texts_historical th
  WHERE include_historical = true
  AND to_tsvector('simple', th.content) @@ plainto_tsquery('simple', search_term)
  AND (version_filter IS NULL OR COALESCE(th.version_source, 'alexandria_archive') = version_filter)
  
  ORDER BY relevance_score DESC, commentary_name, canto_id
  LIMIT result_limit;
END;
$$;

-- 2. Create embedded resource helper functions for test queries
CREATE OR REPLACE FUNCTION get_current_texts_with_commentaries(
  commentary_filter VARCHAR(64) DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  doc_id VARCHAR(12),
  cantica cantica_type,
  canto_id INTEGER,
  content TEXT,
  commentary_data JSONB
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    t.id,
    t.doc_id,
    t.cantica,
    t.canto_id,
    t.content,
    jsonb_build_object(
      'id', c.id,
      'comm_name', c.comm_name,
      'comm_author', c.comm_author,
      'comm_lang', c.comm_lang
    ) as commentary_data
  FROM dde_texts t
  JOIN dde_commentaries c ON t.commentary_id = c.id
  WHERE (commentary_filter IS NULL OR c.comm_name = commentary_filter)
  LIMIT 10;
END;
$$;

-- 3. Grant permissions
GRANT EXECUTE ON FUNCTION get_current_texts_with_commentaries(VARCHAR) TO anon, authenticated;
