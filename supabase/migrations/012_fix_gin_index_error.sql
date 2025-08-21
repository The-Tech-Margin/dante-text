-- Fix GIN index operator class error

-- 1. Corrected search function (same as before)
CREATE OR REPLACE FUNCTION alex_scholarly_search_all_versions(
  search_term TEXT,
  include_historical BOOLEAN DEFAULT true,
  version_filter version_source DEFAULT NULL,
  result_limit INTEGER DEFAULT 20
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
  -- Use INSERT INTO temporary table approach to avoid UNION issues
  CREATE TEMP TABLE IF NOT EXISTS temp_search_results (
    commentary_name VARCHAR(64),
    version_source version_source,
    cantica cantica_type,
    canto_id INTEGER,
    content_match TEXT,
    is_historical BOOLEAN,
    relevance_score REAL
  );
  
  -- Clear any existing data
  DELETE FROM temp_search_results;
  
  -- Insert current texts
  INSERT INTO temp_search_results
  SELECT 
    c.comm_name,
    'current_2024'::version_source,
    t.cantica,
    t.canto_id,
    LEFT(t.content, 100) as content_match,
    false as is_historical,
    1.0::REAL as relevance_score
  FROM dde_texts t
  JOIN dde_commentaries c ON t.commentary_id = c.id
  WHERE t.content ILIKE '%' || search_term || '%'
  AND (version_filter IS NULL OR version_filter = 'current_2024')
  LIMIT 10;
  
  -- Insert historical texts if enabled
  IF include_historical THEN
    INSERT INTO temp_search_results
    SELECT 
      th.commentary_name,
      COALESCE(th.version_source, 'alexandria_archive'::version_source),
      th.cantica,
      th.canto_id,
      LEFT(th.content, 100) as content_match,
      true as is_historical,
      1.0::REAL as relevance_score
    FROM alex_texts_historical th
    WHERE th.content ILIKE '%' || search_term || '%'
    AND (version_filter IS NULL OR COALESCE(th.version_source, 'alexandria_archive') = version_filter)
    LIMIT 10;
  END IF;
  
  -- Return results
  RETURN QUERY
  SELECT 
    tsr.commentary_name,
    tsr.version_source,
    tsr.cantica,
    tsr.canto_id,
    tsr.content_match,
    tsr.is_historical,
    tsr.relevance_score
  FROM temp_search_results tsr
  ORDER BY tsr.is_historical, tsr.commentary_name, tsr.canto_id
  LIMIT result_limit;
  
  -- Clean up
  DROP TABLE temp_search_results;
END;
$$;

-- 2. Update the embedded resource table
DROP TABLE IF EXISTS dde_texts_with_commentary;

CREATE TABLE dde_texts_with_commentary AS
SELECT 
  t.id,
  t.doc_id,
  t.commentary_id,
  t.cantica,
  t.canto_id,
  t.start_line,
  t.end_line,
  t.content,
  -- Pre-computed commentary data as JSONB for embedded access
  jsonb_build_object(
    'id', c.id,
    'comm_id', c.comm_id,
    'comm_name', c.comm_name,
    'comm_author', c.comm_author,
    'comm_lang', c.comm_lang,
    'comm_pub_year', c.comm_pub_year
  ) as dde_commentaries
FROM dde_texts t
JOIN dde_commentaries c ON t.commentary_id = c.id;

-- 3. Create indexes with correct types (fix GIN error)
-- Use BTREE index for text extraction from JSONB instead of GIN
CREATE INDEX IF NOT EXISTS idx_dde_texts_with_commentary_comm_name 
ON dde_texts_with_commentary USING btree((dde_commentaries->>'comm_name'));

-- Use standard BTREE for passage lookup
CREATE INDEX IF NOT EXISTS idx_dde_texts_with_commentary_passage 
ON dde_texts_with_commentary(cantica, canto_id);

-- Use GIN on the full JSONB column (this will work)
CREATE INDEX IF NOT EXISTS idx_dde_texts_with_commentary_jsonb 
ON dde_texts_with_commentary USING gin(dde_commentaries);

-- 4. Enable RLS and create policy
ALTER TABLE dde_texts_with_commentary ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access on dde_texts_with_commentary" ON dde_texts_with_commentary;

CREATE POLICY "Allow public read access on dde_texts_with_commentary" 
ON dde_texts_with_commentary FOR SELECT 
USING (true);

-- 5. Grant permissions
GRANT SELECT ON dde_texts_with_commentary TO anon, authenticated;
