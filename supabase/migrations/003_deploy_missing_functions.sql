-- Deploy missing Supabase functions for Dante Database Frontend
-- These functions were missing from the deployed schema

-- Drop existing functions first to avoid parameter conflicts
DROP FUNCTION IF EXISTS get_commentary_stats(uuid);
DROP FUNCTION IF EXISTS compare_commentaries_by_passage(cantica_type, integer, integer, integer);
DROP FUNCTION IF EXISTS get_navigation_tree(uuid);

-- 1. COMMENTARY STATISTICS FOR DASHBOARD
CREATE OR REPLACE FUNCTION get_commentary_stats(input_commentary_id UUID)
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
  WHERE t.commentary_id = input_commentary_id;
END;
$$;

-- 2. CROSS-COMMENTARY ANALYSIS
CREATE OR REPLACE FUNCTION compare_commentaries_by_passage(
  input_cantica cantica_type,
  input_canto INTEGER,
  input_start_line INTEGER,
  input_end_line INTEGER
)
RETURNS TABLE (
  commentary_id UUID,
  commentary_name VARCHAR(64),
  author VARCHAR(256),
  language language_type,
  text_excerpt TEXT,
  coverage_score REAL
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id::UUID,
    c.comm_name::VARCHAR(64),
    c.comm_author::VARCHAR(256),
    c.comm_lang::language_type,
    LEFT(t.content, 500)::TEXT,
    (
      LEAST(t.end_line, input_end_line) - GREATEST(t.start_line, input_start_line) + 1
    )::REAL / (input_end_line - input_start_line + 1)::REAL
  FROM dde_texts t
  JOIN dde_commentaries c ON t.commentary_id = c.id
  WHERE 
    t.cantica = input_cantica AND
    t.canto_id = input_canto AND
    t.start_line <= input_end_line AND
    t.end_line >= input_start_line
  ORDER BY coverage_score DESC, c.comm_name;
END;
$$;

-- 3. NAVIGATION TREE FOR HIERARCHICAL BROWSING
CREATE OR REPLACE FUNCTION get_navigation_tree(commentary_id UUID DEFAULT NULL)
RETURNS TABLE (
  cantica cantica_type,
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
    t.cantica::cantica_type,
    t.canto_id::INTEGER,
    COUNT(*)::INTEGER as text_count,
    (MIN(t.start_line)::TEXT || '-' || MAX(t.end_line)::TEXT)::TEXT as line_range,
    (COUNT(*) > 0)::BOOLEAN as has_texts
  FROM dde_texts t
  WHERE (get_navigation_tree.commentary_id IS NULL OR t.commentary_id = get_navigation_tree.commentary_id)
  GROUP BY t.cantica, t.canto_id
  ORDER BY t.cantica, t.canto_id;
END;
$$;

-- Grant permissions for web app access
GRANT EXECUTE ON FUNCTION get_commentary_stats(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION compare_commentaries_by_passage(cantica_type, INTEGER, INTEGER, INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_navigation_tree(UUID) TO anon, authenticated;
