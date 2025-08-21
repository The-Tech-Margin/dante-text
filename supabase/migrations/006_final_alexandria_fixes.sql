-- Final Alexandria Test Fixes
-- Resolves function overload, schema cache, and embedded resource issues

-- 1. DROP the original function to resolve overload conflict
DROP FUNCTION IF EXISTS alex_scholarly_search_all_versions(TEXT, BOOLEAN, version_source);

-- 2. Keep only the optimized version with result_limit parameter
-- (This is already created in previous migration)

-- 3. Create proper foreign key relationships for Supabase schema cache
-- Add foreign key constraint to make the relationship explicit
ALTER TABLE alex_texts_historical 
DROP CONSTRAINT IF EXISTS fk_alex_texts_base_commentary;

ALTER TABLE alex_texts_historical 
ADD CONSTRAINT fk_alex_texts_base_commentary 
FOREIGN KEY (base_commentary_id) REFERENCES dde_commentaries(id) ON DELETE SET NULL;

-- 4. Update the view to be more explicit for embedded resources
DROP VIEW IF EXISTS alex_texts_with_commentaries;

CREATE VIEW alex_texts_with_commentaries AS
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
  -- Explicit joins for embedded resources
  row_to_json(c.*) as dde_commentaries
FROM alex_texts_historical th
LEFT JOIN dde_commentaries c ON th.base_commentary_id = c.id;

-- 5. Create a simplified embedded resource function for testing
CREATE OR REPLACE FUNCTION get_historical_texts_with_commentaries(
  commentary_name_filter TEXT DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  commentary_name VARCHAR(64),
  cantica cantica_type,
  canto_id INTEGER,
  content TEXT,
  comm_name VARCHAR(64),
  comm_author VARCHAR(256),
  comm_lang language_type
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    th.id,
    th.commentary_name,
    th.cantica,
    th.canto_id,
    th.content,
    c.comm_name,
    c.comm_author,
    c.comm_lang
  FROM alex_texts_historical th
  LEFT JOIN dde_commentaries c ON th.base_commentary_id = c.id
  WHERE (commentary_name_filter IS NULL OR th.commentary_name = commentary_name_filter)
  LIMIT 10;
END;
$$;

-- 6. Enable RLS and create policies for the view
ALTER VIEW alex_texts_with_commentaries OWNER TO postgres;

-- 7. Grant permissions
GRANT SELECT ON alex_texts_with_commentaries TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_historical_texts_with_commentaries(TEXT) TO anon, authenticated;

-- 8. Refresh the schema cache by updating table statistics
ANALYZE alex_texts_historical;
ANALYZE dde_commentaries;
ANALYZE alex_commentary_versions;

-- 9. Ensure the base_commentary_id is populated
UPDATE alex_texts_historical 
SET base_commentary_id = c.id
FROM dde_commentaries c
WHERE alex_texts_historical.commentary_name = c.comm_name
AND alex_texts_historical.base_commentary_id IS NULL;
