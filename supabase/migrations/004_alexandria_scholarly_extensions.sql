-- Alexandria Archive Scholarly Research Extensions
-- Enables historical commentary analysis and version tracking

-- 1. VERSION TRACKING SYSTEM
CREATE TYPE version_source AS ENUM (
  'original_1991',
  'post_1991', 
  'current_2024',
  'alexandria_archive',
  'unknown'
);

CREATE TYPE editorial_status AS ENUM (
  'published',
  'draft',
  'revision',
  'archived',
  'fragment'
);

-- 2. EXTENDED COMMENTARY METADATA
CREATE TABLE alex_commentary_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  base_commentary_id UUID REFERENCES dde_commentaries(id),
  version_identifier VARCHAR(64) NOT NULL,
  version_source version_source NOT NULL,
  editorial_status editorial_status DEFAULT 'published',
  date_created DATE,
  date_archived DATE,
  editor_notes TEXT,
  provenance_info JSONB,
  file_path TEXT, -- Original Alexandria path
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. HISTORICAL TEXT SEGMENTS
CREATE TABLE alex_texts_historical (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  commentary_version_id UUID,
  
  -- LOGICAL LINKING (No Foreign Key Constraints)
  commentary_name VARCHAR(64) NOT NULL, -- Links to dde_commentaries.comm_name
  cantica cantica_type NOT NULL,
  canto_id INTEGER NOT NULL,
  start_line INTEGER NOT NULL,
  end_line INTEGER NOT NULL,
  content TEXT NOT NULL,
  text_type text_type NOT NULL,
  text_language language_type NOT NULL,
  
  -- SCHOLARLY PROVENANCE
  original_file_path VARCHAR(255), -- Alexandria archive source path
  variant_notes TEXT, -- Textual variant descriptions
  editorial_changes JSONB DEFAULT '{}', -- What changed from original
  original_encoding VARCHAR(32),
  
  -- MATCHING METADATA
  modern_equivalent_found BOOLEAN DEFAULT FALSE, -- Has matching modern text
  similarity_score DECIMAL(3,2), -- Computed similarity to modern version
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. SCHOLARLY ANNOTATIONS
CREATE TABLE alex_scholarly_annotations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text_id UUID, -- Can reference either current or historical texts
  annotation_type VARCHAR(64) NOT NULL, -- 'editorial_note', 'scholarly_comment', 'variant_reading'
  content TEXT NOT NULL,
  author_name VARCHAR(256),
  institution VARCHAR(256),
  date_created DATE,
  citation_info JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. COMMENTARY RELATIONSHIPS
CREATE TABLE alex_commentary_relationships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_commentary_id UUID REFERENCES dde_commentaries(id),
  target_commentary_id UUID REFERENCES dde_commentaries(id),
  relationship_type VARCHAR(64) NOT NULL, -- 'derives_from', 'influences', 'responds_to', 'contemporaneous'
  evidence_description TEXT,
  confidence_level INTEGER CHECK (confidence_level BETWEEN 1 AND 5),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. RESEARCH COLLECTIONS
CREATE TABLE alex_research_collections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  collection_name VARCHAR(256) NOT NULL,
  description TEXT,
  curator_name VARCHAR(256),
  institution VARCHAR(256),
  public_access BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE alex_collection_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  collection_id UUID REFERENCES alex_research_collections(id),
  item_type VARCHAR(64) NOT NULL, -- 'commentary', 'text_segment', 'annotation'
  item_id UUID NOT NULL, -- References various tables
  notes TEXT,
  sort_order INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. ALEXANDRIA MIGRATION TRACKING
CREATE TABLE alex_migration_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  original_path TEXT NOT NULL,
  migrated_to_table VARCHAR(64),
  migrated_record_id UUID,
  migration_status VARCHAR(32) DEFAULT 'pending',
  error_message TEXT,
  metadata JSONB,
  migrated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. INDEXES FOR PERFORMANCE
CREATE INDEX idx_alex_commentary_versions_base ON alex_commentary_versions(base_commentary_id);
CREATE INDEX idx_alex_commentary_versions_source ON alex_commentary_versions(version_source);
CREATE INDEX idx_alex_texts_historical_version ON alex_texts_historical(commentary_version_id);
CREATE INDEX idx_alex_texts_historical_passage ON alex_texts_historical(cantica, canto_id, start_line, end_line);
CREATE INDEX idx_alex_texts_historical_commentary ON alex_texts_historical(commentary_name);
CREATE INDEX idx_alex_annotations_text ON alex_scholarly_annotations(text_id);
CREATE INDEX idx_alex_annotations_type ON alex_scholarly_annotations(annotation_type);
CREATE INDEX idx_alex_relationships_source ON alex_commentary_relationships(source_commentary_id);
CREATE INDEX idx_alex_relationships_target ON alex_commentary_relationships(target_commentary_id);
CREATE INDEX idx_alex_collection_items_collection ON alex_collection_items(collection_id);

-- 9. SCHOLARLY RESEARCH FUNCTIONS

-- Compare historical versions of a commentary
CREATE OR REPLACE FUNCTION alex_compare_commentary_versions(
  input_commentary_name VARCHAR(64)
)
RETURNS TABLE (
  version_id UUID,
  version_source version_source,
  version_identifier VARCHAR(64),
  text_count INTEGER,
  date_created DATE,
  editor_notes TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    cv.id,
    cv.version_source,
    cv.version_identifier,
    COUNT(th.id)::INTEGER as text_count,
    cv.date_created,
    cv.editor_notes
  FROM alex_commentary_versions cv
  JOIN dde_commentaries c ON cv.base_commentary_id = c.id
  LEFT JOIN alex_texts_historical th ON cv.id = th.commentary_version_id
  WHERE c.comm_name = input_commentary_name
  GROUP BY cv.id, cv.version_source, cv.version_identifier, cv.date_created, cv.editor_notes
  ORDER BY cv.date_created DESC NULLS LAST;
END;
$$;

-- Find textual variants for a specific passage
CREATE OR REPLACE FUNCTION alex_find_passage_variants(
  input_cantica cantica_type,
  input_canto INTEGER,
  input_start_line INTEGER,
  input_end_line INTEGER
)
RETURNS TABLE (
  commentary_name VARCHAR(64),
  version_source version_source,
  content_preview TEXT,
  editorial_changes JSONB,
  variant_notes TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.comm_name,
    cv.version_source,
    LEFT(th.content, 300) as content_preview,
    th.editorial_changes,
    th.variant_notes
  FROM alex_texts_historical th
  JOIN alex_commentary_versions cv ON th.commentary_version_id = cv.id
  JOIN dde_commentaries c ON cv.base_commentary_id = c.id
  WHERE 
    th.cantica = input_cantica AND
    th.canto_id = input_canto AND
    th.start_line <= input_end_line AND
    th.end_line >= input_start_line
  ORDER BY c.comm_name, cv.version_source;
END;
$$;

-- Track commentary influence networks
CREATE OR REPLACE FUNCTION alex_get_commentary_network(
  input_commentary_id UUID,
  max_depth INTEGER DEFAULT 2
)
RETURNS TABLE (
  source_name VARCHAR(64),
  target_name VARCHAR(64),
  relationship_type VARCHAR(64),
  confidence_level INTEGER,
  depth_level INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Recursive query to build influence network
  RETURN QUERY
  WITH RECURSIVE commentary_network AS (
    -- Base case: direct relationships
    SELECT 
      c1.comm_name as source_name,
      c2.comm_name as target_name,
      cr.relationship_type,
      cr.confidence_level,
      1 as depth_level
    FROM alex_commentary_relationships cr
    JOIN dde_commentaries c1 ON cr.source_commentary_id = c1.id
    JOIN dde_commentaries c2 ON cr.target_commentary_id = c2.id
    WHERE cr.source_commentary_id = input_commentary_id OR cr.target_commentary_id = input_commentary_id
    
    UNION
    
    -- Recursive case: indirect relationships
    SELECT 
      c1.comm_name,
      c2.comm_name,
      cr.relationship_type,
      cr.confidence_level,
      cn.depth_level + 1
    FROM commentary_network cn
    JOIN alex_commentary_relationships cr ON cr.source_commentary_id = (
      SELECT id FROM dde_commentaries WHERE comm_name = cn.target_name
    )
    JOIN dde_commentaries c1 ON cr.source_commentary_id = c1.id
    JOIN dde_commentaries c2 ON cr.target_commentary_id = c2.id
    WHERE cn.depth_level < max_depth
  )
  SELECT * FROM commentary_network
  ORDER BY depth_level, confidence_level DESC;
END;
$$;

-- Advanced scholarly search across all versions
CREATE OR REPLACE FUNCTION alex_scholarly_search_all_versions(
  search_term TEXT,
  include_historical BOOLEAN DEFAULT true,
  version_filter version_source DEFAULT NULL
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
  -- Search current texts
  SELECT 
    c.comm_name,
    'current_2024'::version_source,
    t.cantica,
    t.canto_id,
    t.content as content_match,
    false as is_historical,
    ts_rank(to_tsvector('english', t.content), plainto_tsquery('english', search_term)) as relevance_score
  FROM dde_texts t
  JOIN dde_commentaries c ON t.commentary_id = c.id
  WHERE to_tsvector('english', t.content) @@ plainto_tsquery('english', search_term)
  AND (version_filter IS NULL OR version_filter = 'current_2024')
  
  UNION ALL
  
  -- Search historical texts (if enabled)
  SELECT 
    c.comm_name,
    cv.version_source,
    th.cantica,
    th.canto_id,
    th.content as content_match,
    true as is_historical,
    ts_rank(to_tsvector('english', th.content), plainto_tsquery('english', search_term)) as relevance_score
  FROM alex_texts_historical th
  JOIN alex_commentary_versions cv ON th.commentary_version_id = cv.id
  JOIN dde_commentaries c ON cv.base_commentary_id = c.id
  WHERE include_historical = true
  AND to_tsvector('english', th.content) @@ plainto_tsquery('english', search_term)
  AND (version_filter IS NULL OR cv.version_source = version_filter)
  
  ORDER BY relevance_score DESC, commentary_name, canto_id;
END;
$$;

-- Grant permissions
GRANT ALL ON alex_commentary_versions TO anon, authenticated;
GRANT ALL ON alex_texts_historical TO anon, authenticated;
GRANT ALL ON alex_scholarly_annotations TO anon, authenticated;
GRANT ALL ON alex_commentary_relationships TO anon, authenticated;
GRANT ALL ON alex_research_collections TO anon, authenticated;
GRANT ALL ON alex_collection_items TO anon, authenticated;
GRANT ALL ON alex_migration_log TO anon, authenticated;

GRANT EXECUTE ON FUNCTION alex_compare_commentary_versions(VARCHAR) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION alex_find_passage_variants(cantica_type, INTEGER, INTEGER, INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION alex_get_commentary_network(UUID, INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION alex_scholarly_search_all_versions(TEXT, BOOLEAN, version_source) TO anon, authenticated;
