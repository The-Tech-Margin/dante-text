-- Final fixes for remaining test failures

-- 1. Fix UNION syntax by using a simpler approach without ORDER BY in subqueries
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
  -- Use a temporary table approach to avoid UNION ORDER BY issues
  RETURN QUERY
  WITH combined_search AS (
    -- Current texts
    SELECT 
      c.comm_name as commentary_name,
      'current_2024'::version_source as version_source,
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
    
    -- Historical texts (if enabled)
    SELECT 
      th.commentary_name,
      COALESCE(th.version_source, 'alexandria_archive'::version_source) as version_source,
      th.cantica,
      th.canto_id,
      LEFT(th.content, 200) as content_match,
      true as is_historical,
      ts_rank(to_tsvector('simple', th.content), plainto_tsquery('simple', search_term)) as relevance_score
    FROM alex_texts_historical th
    WHERE include_historical = true
    AND to_tsvector('simple', th.content) @@ plainto_tsquery('simple', search_term)
    AND (version_filter IS NULL OR COALESCE(th.version_source, 'alexandria_archive') = version_filter)
  )
  SELECT 
    cs.commentary_name,
    cs.version_source,
    cs.cantica,
    cs.canto_id,
    cs.content_match,
    cs.is_historical,
    cs.relevance_score
  FROM combined_search cs
  ORDER BY cs.relevance_score DESC, cs.commentary_name, cs.canto_id
  LIMIT result_limit;
END;
$$;

-- 2. Create a materialized view to fix embedded resource relationships
CREATE MATERIALIZED VIEW IF NOT EXISTS dde_texts_with_commentary AS
SELECT 
  t.id,
  t.doc_id,
  t.commentary_id,
  t.cantica,
  t.canto_id,
  t.start_line,
  t.end_line,
  t.text_language,
  t.text_type,
  t.source_path,
  t.content,
  t.created_at,
  t.updated_at,
  -- Commentary fields embedded
  c.comm_id,
  c.comm_name,
  c.comm_author,
  c.comm_lang,
  c.comm_pub_year,
  c.comm_biblio
FROM dde_texts t
JOIN dde_commentaries c ON t.commentary_id = c.id;

-- 3. Create index on the materialized view
CREATE INDEX IF NOT EXISTS idx_dde_texts_with_commentary_comm_name 
ON dde_texts_with_commentary(comm_name);

CREATE INDEX IF NOT EXISTS idx_dde_texts_with_commentary_passage 
ON dde_texts_with_commentary(cantica, canto_id, start_line, end_line);

-- 4. Enable RLS on the materialized view
ALTER MATERIALIZED VIEW dde_texts_with_commentary OWNER TO postgres;

-- 5. Create policy for public read access
CREATE POLICY IF NOT EXISTS "Allow public read access on dde_texts_with_commentary" 
ON dde_texts_with_commentary FOR SELECT USING (true);

-- 6. Grant permissions
GRANT SELECT ON dde_texts_with_commentary TO anon, authenticated;

-- 7. Refresh the materialized view
REFRESH MATERIALIZED VIEW dde_texts_with_commentary;
