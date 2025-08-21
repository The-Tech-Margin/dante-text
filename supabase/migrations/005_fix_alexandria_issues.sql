-- Fix Alexandria Test Failures
-- Addresses timeout, linking, and schema issues

-- 1. Add missing version_source column to alex_texts_historical
ALTER TABLE alex_texts_historical 
ADD COLUMN IF NOT EXISTS version_source version_source DEFAULT 'alexandria_archive';

-- 2. Create proper foreign key for logical linking
ALTER TABLE alex_texts_historical 
ADD COLUMN IF NOT EXISTS base_commentary_id UUID;

-- Create index for the new column
CREATE INDEX IF NOT EXISTS idx_alex_texts_historical_base_commentary 
ON alex_texts_historical(base_commentary_id);

-- 3. Create a view for logical linking that Supabase can understand
CREATE OR REPLACE VIEW alex_texts_with_commentaries AS
SELECT 
  th.id,
  th.commentary_version_id,
  th.commentary_name,
  th.cantica,
  th.canto_id,
  th.start_line,
  th.end_line,
  th.content,
  th.text_type,
  th.text_language,
  th.version_source,
  th.base_commentary_id,
  c.id as current_commentary_id,
  c.comm_name as current_comm_name,
  c.comm_author as current_comm_author,
  c.comm_lang as current_comm_lang
FROM alex_texts_historical th
LEFT JOIN dde_commentaries c ON th.commentary_name = c.comm_name;

-- 4. Optimize alex_scholarly_search_all_versions to prevent timeouts
CREATE OR REPLACE FUNCTION alex_scholarly_search_all_versions(
  search_term TEXT,
  include_historical BOOLEAN DEFAULT true,
  version_filter version_source DEFAULT NULL,
  result_limit INTEGER DEFAULT 50  -- Add limit parameter
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
  SELECT * FROM (
    -- Search current texts with LIMIT
    SELECT 
      c.comm_name,
      'current_2024'::version_source,
      t.cantica,
      t.canto_id,
      LEFT(t.content, 200) as content_match, -- Truncate content for performance
      false as is_historical,
      ts_rank(to_tsvector('simple', t.content), plainto_tsquery('simple', search_term)) as relevance_score
    FROM dde_texts t
    JOIN dde_commentaries c ON t.commentary_id = c.id
    WHERE to_tsvector('simple', t.content) @@ plainto_tsquery('simple', search_term)
    AND (version_filter IS NULL OR version_filter = 'current_2024')
    ORDER BY ts_rank(to_tsvector('simple', t.content), plainto_tsquery('simple', search_term)) DESC
    LIMIT GREATEST(result_limit / 2, 10) -- Split limit between current and historical
    
  ) current_results
  
  UNION ALL
  
  SELECT * FROM (
    -- Search historical texts with LIMIT (if enabled)
    SELECT 
      th.commentary_name,
      COALESCE(th.version_source, 'alexandria_archive'::version_source),
      th.cantica,
      th.canto_id,
      LEFT(th.content, 200) as content_match, -- Truncate content for performance
      true as is_historical,
      ts_rank(to_tsvector('simple', th.content), plainto_tsquery('simple', search_term)) as relevance_score
    FROM alex_texts_historical th
    WHERE include_historical = true
    AND to_tsvector('simple', th.content) @@ plainto_tsquery('simple', search_term)
    AND (version_filter IS NULL OR COALESCE(th.version_source, 'alexandria_archive') = version_filter)
    ORDER BY ts_rank(to_tsvector('simple', th.content), plainto_tsquery('simple', search_term)) DESC
    LIMIT GREATEST(result_limit / 2, 10) -- Split limit between current and historical
    
  ) historical_results
  WHERE include_historical = true
  
  ORDER BY relevance_score DESC, commentary_name, canto_id
  LIMIT result_limit;
END;
$$;

-- 5. Create function to populate linking data
CREATE OR REPLACE FUNCTION alex_populate_base_commentary_links()
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  updated_count INTEGER := 0;
BEGIN
  -- Link historical texts to current commentaries by name
  UPDATE alex_texts_historical 
  SET base_commentary_id = c.id
  FROM dde_commentaries c
  WHERE alex_texts_historical.commentary_name = c.comm_name
  AND alex_texts_historical.base_commentary_id IS NULL;
  
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count;
END;
$$;

-- 6. Add GIN indexes for better full-text search performance
CREATE INDEX IF NOT EXISTS idx_alex_texts_historical_content_gin 
ON alex_texts_historical USING gin(to_tsvector('simple', content));

CREATE INDEX IF NOT EXISTS idx_alex_texts_historical_version_source 
ON alex_texts_historical(version_source);

-- 7. Grant permissions on new objects
GRANT SELECT ON alex_texts_with_commentaries TO anon, authenticated;
GRANT EXECUTE ON FUNCTION alex_populate_base_commentary_links() TO authenticated;
GRANT EXECUTE ON FUNCTION alex_scholarly_search_all_versions(TEXT, BOOLEAN, version_source, INTEGER) TO anon, authenticated;

-- 8. Populate the linking data
SELECT alex_populate_base_commentary_links();
