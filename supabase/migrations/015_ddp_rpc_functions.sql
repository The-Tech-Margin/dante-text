-- DDP RPC Functions and Cross-Table Integration
-- Creates functions for ddp_ tables and unified alex_/ddp_ queries

-- ===================================================================
-- 1. DDP CORE FUNCTIONS (equivalent to alex_ functions)
-- ===================================================================

-- Search current commentaries (ddp_ equivalent of alex_scholarly_search_all_versions)
CREATE OR REPLACE FUNCTION ddp_search_commentaries(
  search_term TEXT,
  commentary_filter VARCHAR(64) DEFAULT NULL,
  cantica_filter cantica_type DEFAULT NULL,
  result_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
  commentary_name VARCHAR(64),
  cantica cantica_type,
  canto_id INTEGER,
  content_match TEXT,
  relevance_score REAL,
  text_type text_type,
  language language_type
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.comm_name,
    t.cantica,
    t.canto_id,
    LEFT(t.content, 200) as content_match,
    ts_rank(to_tsvector('english', t.content), plainto_tsquery('english', search_term)) as relevance_score,
    t.text_type,
    t.text_language
  FROM dde_texts t
  JOIN dde_commentaries c ON t.commentary_id = c.id
  WHERE to_tsvector('english', t.content) @@ plainto_tsquery('english', search_term)
  AND (commentary_filter IS NULL OR c.comm_name = commentary_filter)
  AND (cantica_filter IS NULL OR t.cantica = cantica_filter)
  ORDER BY ts_rank(to_tsvector('english', t.content), plainto_tsquery('english', search_term)) DESC
  LIMIT result_limit;
END;
$$;

-- Get commentary statistics (ddp_ equivalent)
CREATE OR REPLACE FUNCTION ddp_get_commentary_stats(
  input_commentary_name VARCHAR(64)
)
RETURNS TABLE (
  commentary_name VARCHAR(64),
  text_count INTEGER,
  canticas_covered TEXT[],
  total_lines INTEGER,
  avg_text_length INTEGER,
  last_updated TIMESTAMPTZ
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.comm_name,
    COUNT(t.id)::INTEGER as text_count,
    ARRAY_AGG(DISTINCT t.cantica::TEXT) as canticas_covered,
    COALESCE(SUM(t.end_line - t.start_line + 1), 0)::INTEGER as total_lines,
    COALESCE(AVG(LENGTH(t.content)), 0)::INTEGER as avg_text_length,
    MAX(t.updated_at) as last_updated
  FROM dde_commentaries c
  LEFT JOIN dde_texts t ON c.id = t.commentary_id
  WHERE c.comm_name = input_commentary_name
  GROUP BY c.comm_name;
END;
$$;

-- Find passages in current commentaries
CREATE OR REPLACE FUNCTION ddp_find_passages(
  input_cantica cantica_type,
  input_canto INTEGER,
  input_start_line INTEGER,
  input_end_line INTEGER
)
RETURNS TABLE (
  commentary_name VARCHAR(64),
  content_preview TEXT,
  start_line INTEGER,
  end_line INTEGER,
  text_type text_type,
  language language_type
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.comm_name,
    LEFT(t.content, 300) as content_preview,
    t.start_line,
    t.end_line,
    t.text_type,
    t.text_language
  FROM dde_texts t
  JOIN dde_commentaries c ON t.commentary_id = c.id
  WHERE 
    t.cantica = input_cantica AND
    t.canto_id = input_canto AND
    t.start_line <= input_end_line AND
    t.end_line >= input_start_line
  ORDER BY c.comm_name, t.start_line;
END;
$$;

-- Get table information for ddp_ tables
CREATE OR REPLACE FUNCTION get_ddp_tables_info()
RETURNS TABLE (
  table_name TEXT,
  row_count BIGINT,
  total_columns INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    'dde_commentaries'::TEXT,
    (SELECT COUNT(*) FROM dde_commentaries),
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'dde_commentaries')::INTEGER
  UNION ALL
  SELECT
    'dde_texts'::TEXT,
    (SELECT COUNT(*) FROM dde_texts),
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'dde_texts')::INTEGER
  UNION ALL
  SELECT
    'dde_texts_with_commentary'::TEXT,
    (SELECT COUNT(*) FROM dde_texts_with_commentary),
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'dde_texts_with_commentary')::INTEGER;
END;
$$;

-- ===================================================================
-- 2. CROSS-TABLE UNIFIED FUNCTIONS (query both alex_ and ddp_)
-- ===================================================================

-- Unified search across both historical and current texts
CREATE OR REPLACE FUNCTION unified_search_all_texts(
  search_term TEXT,
  include_historical BOOLEAN DEFAULT true,
  include_current BOOLEAN DEFAULT true,
  commentary_filter VARCHAR(64) DEFAULT NULL,
  result_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
  commentary_name VARCHAR(64),
  source_system TEXT,
  version_source TEXT,
  cantica cantica_type,
  canto_id INTEGER,
  content_match TEXT,
  is_historical BOOLEAN,
  relevance_score REAL,
  start_line INTEGER,
  end_line INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM (
    -- Current texts (ddp_ system)
    SELECT 
      c.comm_name,
      'ddp_current'::TEXT as source_system,
      'current_2024'::TEXT as version_source,
      t.cantica,
      t.canto_id,
      LEFT(t.content, 200) as content_match,
      false as is_historical,
      ts_rank(to_tsvector('english', t.content), plainto_tsquery('english', search_term)) as relevance_score,
      t.start_line,
      t.end_line
    FROM dde_texts t
    JOIN dde_commentaries c ON t.commentary_id = c.id
    WHERE include_current = true
    AND to_tsvector('english', t.content) @@ plainto_tsquery('english', search_term)
    AND (commentary_filter IS NULL OR c.comm_name = commentary_filter)
    
    UNION ALL
    
    -- Historical texts (alex_ system)
    SELECT 
      th.commentary_name,
      'alex_historical'::TEXT as source_system,
      cv.version_source::TEXT,
      th.cantica,
      th.canto_id,
      LEFT(th.content, 200) as content_match,
      true as is_historical,
      ts_rank(to_tsvector('english', th.content), plainto_tsquery('english', search_term)) as relevance_score,
      th.start_line,
      th.end_line
    FROM alex_texts_historical th
    JOIN alex_commentary_versions cv ON th.commentary_version_id = cv.id
    WHERE include_historical = true
    AND to_tsvector('english', th.content) @@ plainto_tsquery('english', search_term)
    AND (commentary_filter IS NULL OR th.commentary_name = commentary_filter)
  ) combined_results
  ORDER BY relevance_score DESC, commentary_name, canto_id
  LIMIT result_limit;
END;
$$;

-- Compare commentary across systems (current vs historical)
CREATE OR REPLACE FUNCTION unified_compare_commentary_versions(
  input_commentary_name VARCHAR(64)
)
RETURNS TABLE (
  commentary_name VARCHAR(64),
  source_system TEXT,
  version_source TEXT,
  text_count INTEGER,
  total_lines INTEGER,
  avg_content_length INTEGER,
  date_info TEXT,
  has_variants BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM (
    -- Current commentary data (ddp_)
    SELECT 
      c.comm_name,
      'ddp_current'::TEXT as source_system,
      'current_2024'::TEXT as version_source,
      COUNT(t.id)::INTEGER as text_count,
      COALESCE(SUM(t.end_line - t.start_line + 1), 0)::INTEGER as total_lines,
      COALESCE(AVG(LENGTH(t.content)), 0)::INTEGER as avg_content_length,
      'Current active version'::TEXT as date_info,
      false as has_variants
    FROM dde_commentaries c
    LEFT JOIN dde_texts t ON c.id = t.commentary_id
    WHERE c.comm_name = input_commentary_name
    GROUP BY c.comm_name
    
    UNION ALL
    
    -- Historical commentary versions (alex_)
    SELECT 
      cv.version_identifier as commentary_name,
      'alex_historical'::TEXT as source_system,
      cv.version_source::TEXT,
      COUNT(th.id)::INTEGER as text_count,
      COALESCE(SUM(th.end_line - th.start_line + 1), 0)::INTEGER as total_lines,
      COALESCE(AVG(LENGTH(th.content)), 0)::INTEGER as avg_content_length,
      COALESCE(cv.date_created::TEXT, 'Unknown date') as date_info,
      COUNT(th.id FILTER (WHERE th.variant_notes IS NOT NULL)) > 0 as has_variants
    FROM alex_commentary_versions cv
    LEFT JOIN alex_texts_historical th ON cv.id = th.commentary_version_id
    JOIN dde_commentaries c ON cv.base_commentary_id = c.id
    WHERE c.comm_name = input_commentary_name
    GROUP BY cv.id, cv.version_identifier, cv.version_source, cv.date_created
  ) combined_versions
  ORDER BY 
    CASE WHEN source_system = 'ddp_current' THEN 1 ELSE 2 END,
    date_info DESC;
END;
$$;

-- Get passage variants across both systems
CREATE OR REPLACE FUNCTION unified_find_passage_variants(
  input_cantica cantica_type,
  input_canto INTEGER,
  input_start_line INTEGER,
  input_end_line INTEGER
)
RETURNS TABLE (
  commentary_name VARCHAR(64),
  source_system TEXT,
  version_source TEXT,
  content_preview TEXT,
  start_line INTEGER,
  end_line INTEGER,
  editorial_changes JSONB,
  variant_notes TEXT,
  is_historical BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM (
    -- Current passages (ddp_)
    SELECT 
      c.comm_name,
      'ddp_current'::TEXT as source_system,
      'current_2024'::TEXT as version_source,
      LEFT(t.content, 300) as content_preview,
      t.start_line,
      t.end_line,
      '{}'::JSONB as editorial_changes,
      NULL::TEXT as variant_notes,
      false as is_historical
    FROM dde_texts t
    JOIN dde_commentaries c ON t.commentary_id = c.id
    WHERE 
      t.cantica = input_cantica AND
      t.canto_id = input_canto AND
      t.start_line <= input_end_line AND
      t.end_line >= input_start_line
    
    UNION ALL
    
    -- Historical passages (alex_)
    SELECT 
      th.commentary_name,
      'alex_historical'::TEXT as source_system,
      cv.version_source::TEXT,
      LEFT(th.content, 300) as content_preview,
      th.start_line,
      th.end_line,
      th.editorial_changes,
      th.variant_notes,
      true as is_historical
    FROM alex_texts_historical th
    JOIN alex_commentary_versions cv ON th.commentary_version_id = cv.id
    WHERE 
      th.cantica = input_cantica AND
      th.canto_id = input_canto AND
      th.start_line <= input_end_line AND
      th.end_line >= input_start_line
  ) combined_passages
  ORDER BY commentary_name, is_historical, start_line;
END;
$$;

-- Get comprehensive system statistics
CREATE OR REPLACE FUNCTION get_unified_system_stats()
RETURNS TABLE (
  system_name TEXT,
  table_name TEXT,
  row_count BIGINT,
  description TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM (
    -- DDP system stats
    SELECT 
      'Digital Dante (DDP)'::TEXT as system_name,
      'dde_commentaries'::TEXT as table_name,
      (SELECT COUNT(*) FROM dde_commentaries) as row_count,
      'Current commentary metadata'::TEXT as description
    UNION ALL
    SELECT 
      'Digital Dante (DDP)'::TEXT,
      'dde_texts'::TEXT,
      (SELECT COUNT(*) FROM dde_texts),
      'Current commentary text segments'::TEXT
    UNION ALL
    SELECT 
      'Digital Dante (DDP)'::TEXT,
      'dde_texts_with_commentary'::TEXT,
      (SELECT COUNT(*) FROM dde_texts_with_commentary),
      'Materialized view for embedded resources'::TEXT
    
    UNION ALL
    
    -- Alexandria system stats
    SELECT 
      'Alexandria Archive (ALEX)'::TEXT as system_name,
      'alex_commentary_versions'::TEXT as table_name,
      (SELECT COUNT(*) FROM alex_commentary_versions) as row_count,
      'Historical commentary versions'::TEXT as description
    UNION ALL
    SELECT 
      'Alexandria Archive (ALEX)'::TEXT,
      'alex_texts_historical'::TEXT,
      (SELECT COUNT(*) FROM alex_texts_historical),
      'Historical text segments'::TEXT
    UNION ALL
    SELECT 
      'Alexandria Archive (ALEX)'::TEXT,
      'alex_scholarly_annotations'::TEXT,
      (SELECT COUNT(*) FROM alex_scholarly_annotations),
      'Editorial notes and annotations'::TEXT
    UNION ALL
    SELECT 
      'Alexandria Archive (ALEX)'::TEXT,
      'alex_commentary_relationships'::TEXT,
      (SELECT COUNT(*) FROM alex_commentary_relationships),
      'Scholarly relationships between commentaries'::TEXT
    UNION ALL
    SELECT 
      'Alexandria Archive (ALEX)'::TEXT,
      'alex_research_collections'::TEXT,
      (SELECT COUNT(*) FROM alex_research_collections),
      'Research collections and groupings'::TEXT
    UNION ALL
    SELECT 
      'Alexandria Archive (ALEX)'::TEXT,
      'alex_collection_items'::TEXT,
      (SELECT COUNT(*) FROM alex_collection_items),
      'Items within research collections'::TEXT
  ) system_stats
  ORDER BY system_name, table_name;
END;
$$;

-- ===================================================================
-- 3. GRANT PERMISSIONS
-- ===================================================================

-- Grant execute permissions on all new functions
GRANT EXECUTE ON FUNCTION ddp_search_commentaries(TEXT, VARCHAR, cantica_type, INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION ddp_get_commentary_stats(VARCHAR) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION ddp_find_passages(cantica_type, INTEGER, INTEGER, INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_ddp_tables_info() TO anon, authenticated;

GRANT EXECUTE ON FUNCTION unified_search_all_texts(TEXT, BOOLEAN, BOOLEAN, VARCHAR, INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION unified_compare_commentary_versions(VARCHAR) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION unified_find_passage_variants(cantica_type, INTEGER, INTEGER, INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_unified_system_stats() TO anon, authenticated;

-- ===================================================================
-- 4. VERIFICATION
-- ===================================================================

-- Log successful creation
DO $$
BEGIN
  RAISE NOTICE 'DDP RPC Functions and Cross-Table Integration Created Successfully';
  RAISE NOTICE 'DDP Functions: ddp_search_commentaries, ddp_get_commentary_stats, ddp_find_passages, get_ddp_tables_info';
  RAISE NOTICE 'Unified Functions: unified_search_all_texts, unified_compare_commentary_versions, unified_find_passage_variants, get_unified_system_stats';
END $$;
