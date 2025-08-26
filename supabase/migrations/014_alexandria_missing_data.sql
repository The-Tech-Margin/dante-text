-- Alexandria Archive Missing Data Migration
-- Populates empty alex_ tables with data from Alexandria-Archive

-- ===================================================================
-- 1. POPULATE COMMENTARY RELATIONSHIPS
-- ===================================================================

-- Create chronological relationships based on LoadOrder sequence
INSERT INTO alex_commentary_relationships (
  source_commentary_id,
  target_commentary_id, 
  relationship_type,
  evidence_description,
  confidence_level
)
SELECT DISTINCT
  c1.id as source_commentary_id,
  c2.id as target_commentary_id,
  'chronological_precedence' as relationship_type,
  'Based on LoadOrder sequence in Alexandria archive' as evidence_description,
  3 as confidence_level
FROM dde_commentaries c1
CROSS JOIN dde_commentaries c2
WHERE c1.comm_name IN (
  'jacopo', 'graziolo', 'lana', 'lombardus', 'guido', 'ottimo', 'selmiano', 
  'pietro1', 'pietro2', 'pietro3', 'cassinese', 'ambrosiane', 'maramauro',
  'cagliaritane', 'boccaccio', 'benvenuto', 'buti', 'vernon', 'fiorentino',
  'villani', 'serravalle', 'guiniforto', 'landino', 'vellutello', 'giambullari',
  'gelli', 'varchi', 'gabriele', 'daniello', 'tasso', 'castelvetro', 'venturi',
  'lombardi', 'portirelli', 'costa', 'rossetti', 'tommaseo', 'andreoli',
  'longfellow', 'disiena', 'bianchi', 'scartazzini', 'campi', 'berthier',
  'poletto', 'oelsner', 'tozer', 'ruskin', 'carroll', 'torraca', 'grandgent',
  'mestica', 'casini', 'steiner', 'dellungo', 'vandelli', 'grabher', 'trucchi',
  'pietrobono', 'momigliano', 'porena', 'sapegno', 'mattalia', 'chimenz',
  'fallani', 'padoan', 'giacalone', 'singleton', 'bosco', 'pasquini',
  'hollander', 'fosca'
)
AND c2.comm_name IN (
  'jacopo', 'graziolo', 'lana', 'lombardus', 'guido', 'ottimo', 'selmiano', 
  'pietro1', 'pietro2', 'pietro3', 'cassinese', 'ambrosiane', 'maramauro',
  'cagliaritane', 'boccaccio', 'benvenuto', 'buti', 'vernon', 'fiorentino',
  'villani', 'serravalle', 'guiniforto', 'landino', 'vellutello', 'giambullari',
  'gelli', 'varchi', 'gabriele', 'daniello', 'tasso', 'castelvetro', 'venturi',
  'lombardi', 'portirelli', 'costa', 'rossetti', 'tommaseo', 'andreoli',
  'longfellow', 'disiena', 'bianchi', 'scartazzini', 'campi', 'berthier',
  'poletto', 'oelsner', 'tozer', 'ruskin', 'carroll', 'torraca', 'grandgent',
  'mestica', 'casini', 'steiner', 'dellungo', 'vandelli', 'grabher', 'trucchi',
  'pietrobono', 'momigliano', 'porena', 'sapegno', 'mattalia', 'chimenz',
  'fallani', 'padoan', 'giacalone', 'singleton', 'bosco', 'pasquini',
  'hollander', 'fosca'
)
AND c1.comm_name != c2.comm_name
-- Create relationships between adjacent commentaries in chronological order
AND (
  (c1.comm_name = 'jacopo' AND c2.comm_name = 'graziolo') OR
  (c1.comm_name = 'graziolo' AND c2.comm_name = 'lana') OR
  (c1.comm_name = 'lana' AND c2.comm_name = 'lombardus') OR
  (c1.comm_name = 'lombardus' AND c2.comm_name = 'guido') OR
  (c1.comm_name = 'guido' AND c2.comm_name = 'ottimo') OR
  (c1.comm_name = 'ottimo' AND c2.comm_name = 'selmiano') OR
  (c1.comm_name = 'selmiano' AND c2.comm_name = 'pietro1') OR
  (c1.comm_name = 'pietro1' AND c2.comm_name = 'pietro2') OR
  (c1.comm_name = 'pietro2' AND c2.comm_name = 'pietro3') OR
  (c1.comm_name = 'pietro3' AND c2.comm_name = 'cassinese') OR
  (c1.comm_name = 'cassinese' AND c2.comm_name = 'ambrosiane') OR
  (c1.comm_name = 'ambrosiane' AND c2.comm_name = 'maramauro') OR
  (c1.comm_name = 'maramauro' AND c2.comm_name = 'cagliaritane') OR
  (c1.comm_name = 'cagliaritane' AND c2.comm_name = 'boccaccio') OR
  (c1.comm_name = 'boccaccio' AND c2.comm_name = 'benvenuto') OR
  (c1.comm_name = 'benvenuto' AND c2.comm_name = 'buti') OR
  (c1.comm_name = 'buti' AND c2.comm_name = 'vernon') OR
  (c1.comm_name = 'vernon' AND c2.comm_name = 'fiorentino') OR
  (c1.comm_name = 'fiorentino' AND c2.comm_name = 'villani') OR
  (c1.comm_name = 'villani' AND c2.comm_name = 'serravalle') OR
  (c1.comm_name = 'serravalle' AND c2.comm_name = 'guiniforto') OR
  (c1.comm_name = 'guiniforto' AND c2.comm_name = 'landino') OR
  (c1.comm_name = 'landino' AND c2.comm_name = 'vellutello') OR
  (c1.comm_name = 'vellutello' AND c2.comm_name = 'giambullari') OR
  (c1.comm_name = 'giambullari' AND c2.comm_name = 'gelli') OR
  (c1.comm_name = 'gelli' AND c2.comm_name = 'varchi') OR
  (c1.comm_name = 'varchi' AND c2.comm_name = 'gabriele') OR
  (c1.comm_name = 'gabriele' AND c2.comm_name = 'daniello') OR
  (c1.comm_name = 'daniello' AND c2.comm_name = 'tasso') OR
  (c1.comm_name = 'tasso' AND c2.comm_name = 'castelvetro') OR
  (c1.comm_name = 'castelvetro' AND c2.comm_name = 'venturi') OR
  (c1.comm_name = 'venturi' AND c2.comm_name = 'lombardi') OR
  (c1.comm_name = 'lombardi' AND c2.comm_name = 'portirelli') OR
  (c1.comm_name = 'portirelli' AND c2.comm_name = 'costa') OR
  (c1.comm_name = 'costa' AND c2.comm_name = 'rossetti') OR
  (c1.comm_name = 'rossetti' AND c2.comm_name = 'tommaseo') OR
  (c1.comm_name = 'tommaseo' AND c2.comm_name = 'andreoli') OR
  (c1.comm_name = 'andreoli' AND c2.comm_name = 'longfellow') OR
  (c1.comm_name = 'longfellow' AND c2.comm_name = 'disiena') OR
  (c1.comm_name = 'disiena' AND c2.comm_name = 'bianchi') OR
  (c1.comm_name = 'bianchi' AND c2.comm_name = 'scartazzini') OR
  (c1.comm_name = 'scartazzini' AND c2.comm_name = 'campi') OR
  (c1.comm_name = 'campi' AND c2.comm_name = 'berthier') OR
  (c1.comm_name = 'berthier' AND c2.comm_name = 'poletto') OR
  (c1.comm_name = 'poletto' AND c2.comm_name = 'oelsner') OR
  (c1.comm_name = 'oelsner' AND c2.comm_name = 'tozer') OR
  (c1.comm_name = 'tozer' AND c2.comm_name = 'ruskin') OR
  (c1.comm_name = 'ruskin' AND c2.comm_name = 'carroll') OR
  (c1.comm_name = 'carroll' AND c2.comm_name = 'torraca') OR
  (c1.comm_name = 'torraca' AND c2.comm_name = 'grandgent') OR
  (c1.comm_name = 'grandgent' AND c2.comm_name = 'mestica') OR
  (c1.comm_name = 'mestica' AND c2.comm_name = 'casini') OR
  (c1.comm_name = 'casini' AND c2.comm_name = 'steiner') OR
  (c1.comm_name = 'steiner' AND c2.comm_name = 'dellungo') OR
  (c1.comm_name = 'dellungo' AND c2.comm_name = 'vandelli') OR
  (c1.comm_name = 'vandelli' AND c2.comm_name = 'grabher') OR
  (c1.comm_name = 'grabher' AND c2.comm_name = 'trucchi') OR
  (c1.comm_name = 'trucchi' AND c2.comm_name = 'pietrobono') OR
  (c1.comm_name = 'pietrobono' AND c2.comm_name = 'momigliano') OR
  (c1.comm_name = 'momigliano' AND c2.comm_name = 'porena') OR
  (c1.comm_name = 'porena' AND c2.comm_name = 'sapegno') OR
  (c1.comm_name = 'sapegno' AND c2.comm_name = 'mattalia') OR
  (c1.comm_name = 'mattalia' AND c2.comm_name = 'chimenz') OR
  (c1.comm_name = 'chimenz' AND c2.comm_name = 'fallani') OR
  (c1.comm_name = 'fallani' AND c2.comm_name = 'padoan') OR
  (c1.comm_name = 'padoan' AND c2.comm_name = 'giacalone') OR
  (c1.comm_name = 'giacalone' AND c2.comm_name = 'singleton') OR
  (c1.comm_name = 'singleton' AND c2.comm_name = 'bosco') OR
  (c1.comm_name = 'bosco' AND c2.comm_name = 'pasquini') OR
  (c1.comm_name = 'pasquini' AND c2.comm_name = 'hollander') OR
  (c1.comm_name = 'hollander' AND c2.comm_name = 'fosca')
);

-- ===================================================================
-- 2. CREATE RESEARCH COLLECTIONS
-- ===================================================================

-- Historical Archive Collections
INSERT INTO alex_research_collections (
  collection_name,
  description,
  curator_name,
  institution,
  public_access
) VALUES 
  (
    'Alexandria Archive 1991 Collection',
    'Original commentaries from the 1991 Alexandria Archive. Historical versions of Dante commentaries preserved from the early digital humanities project.',
    'Alexandria Project Team',
    'Dartmouth College',
    true
  ),
  (
    'Alexandria Archive Post-1991 Collection', 
    'Updated commentary versions from the post-1991 Alexandria Archive. Represents editorial revisions and additions made after the initial digital publication.',
    'Alexandria Project Team',
    'Dartmouth College',
    true
  ),
  (
    'Current Alexandria Archive Collection',
    'Most recent versions of commentaries from the Alexandria Archive. These represent the final state of the digital scholarly edition.',
    'Alexandria Project Team', 
    'Dartmouth College',
    true
  ),
  (
    'Historical Textual Variants Collection',
    'Collection of textual variants and editorial changes identified through comparison of historical and modern commentary versions.',
    'Digital Dante Research Team',
    'Various Institutions',
    true
  );

-- ===================================================================
-- 3. POPULATE COLLECTION ITEMS
-- ===================================================================

-- Link commentary versions to appropriate collections
INSERT INTO alex_collection_items (
  collection_id,
  item_type,
  item_id,
  notes,
  sort_order
)
-- 1991 Archive Collection Items
SELECT 
  (SELECT id FROM alex_research_collections WHERE collection_name = 'Alexandria Archive 1991 Collection'),
  'commentary_version' as item_type,
  cv.id as item_id,
  'Commentary version from 1991 Alexandria Archive' as notes,
  ROW_NUMBER() OVER (ORDER BY cv.version_identifier) as sort_order
FROM alex_commentary_versions cv
WHERE cv.version_source = 'original_1991'

UNION ALL

-- Post-1991 Archive Collection Items  
SELECT
  (SELECT id FROM alex_research_collections WHERE collection_name = 'Alexandria Archive Post-1991 Collection'),
  'commentary_version' as item_type,
  cv.id as item_id,
  'Commentary version from post-1991 Alexandria Archive' as notes,
  ROW_NUMBER() OVER (ORDER BY cv.version_identifier) as sort_order
FROM alex_commentary_versions cv
WHERE cv.version_source = 'post_1991'

UNION ALL

-- Current Archive Collection Items
SELECT
  (SELECT id FROM alex_research_collections WHERE collection_name = 'Current Alexandria Archive Collection'),
  'commentary_version' as item_type,
  cv.id as item_id,
  'Current commentary version from Alexandria Archive' as notes,
  ROW_NUMBER() OVER (ORDER BY cv.version_identifier) as sort_order
FROM alex_commentary_versions cv  
WHERE cv.version_source = 'alexandria_archive'

UNION ALL

-- Historical Variants Collection Items (texts with high similarity scores)
SELECT
  (SELECT id FROM alex_research_collections WHERE collection_name = 'Historical Textual Variants Collection'),
  'text_segment' as item_type,
  th.id as item_id,
  CASE 
    WHEN th.similarity_score > 0.8 THEN 'High similarity variant (>80%)'
    WHEN th.similarity_score > 0.5 THEN 'Medium similarity variant (50-80%)'
    ELSE 'Low similarity variant (<50%)'
  END as notes,
  ROW_NUMBER() OVER (ORDER BY th.similarity_score DESC NULLS LAST) as sort_order
FROM alex_texts_historical th
WHERE th.similarity_score IS NOT NULL AND th.similarity_score > 0.3;

-- ===================================================================
-- 4. CREATE SCHOLARLY ANNOTATIONS FROM DESCRIPTION METADATA
-- ===================================================================

-- Extract scholarly annotations from historical text metadata
INSERT INTO alex_scholarly_annotations (
  text_id,
  annotation_type,
  content,
  author_name,
  institution,
  date_created,
  citation_info
)
-- Editorial notes from commentary versions
SELECT
  cv.id as text_id,
  'editorial_note' as annotation_type,
  cv.editor_notes as content,
  'Alexandria Project Team' as author_name,
  'Dartmouth College' as institution,
  cv.date_created,
  jsonb_build_object(
    'source', 'alexandria_archive',
    'version_identifier', cv.version_identifier,
    'migration_metadata', cv.provenance_info
  ) as citation_info
FROM alex_commentary_versions cv
WHERE cv.editor_notes IS NOT NULL AND LENGTH(cv.editor_notes) > 10

UNION ALL

-- Variant annotations from historical texts  
SELECT
  th.id as text_id,
  'variant_reading' as annotation_type,
  th.variant_notes as content,
  'Historical Editor' as author_name,
  'Unknown' as institution,
  CURRENT_DATE as date_created,
  jsonb_build_object(
    'source', 'alexandria_archive',
    'original_file_path', th.original_file_path,
    'commentary_name', th.commentary_name,
    'cantica', th.cantica,
    'canto_id', th.canto_id
  ) as citation_info
FROM alex_texts_historical th
WHERE th.variant_notes IS NOT NULL AND LENGTH(th.variant_notes) > 5

UNION ALL

-- Editorial change annotations
SELECT
  th.id as text_id,
  'editorial_comment' as annotation_type,
  'Editorial changes identified: ' || th.editorial_changes::text as content,
  'Migration System' as author_name,
  'Digital Dante Project' as institution,
  CURRENT_DATE as date_created,
  jsonb_build_object(
    'source', 'migration_analysis',
    'editorial_changes', th.editorial_changes,
    'similarity_score', th.similarity_score,
    'modern_equivalent_found', th.modern_equivalent_found
  ) as citation_info  
FROM alex_texts_historical th
WHERE th.editorial_changes IS NOT NULL 
AND th.editorial_changes != '{}'::jsonb
AND jsonb_array_length(th.editorial_changes) > 0;

-- ===================================================================
-- 5. UPDATE MIGRATION LOG
-- ===================================================================

-- Log the missing data population
INSERT INTO alex_migration_log (
  original_path,
  migrated_to_table,
  migration_status,
  metadata
) VALUES 
  (
    'supabase/migrations/014_alexandria_missing_data.sql',
    'alex_commentary_relationships,alex_research_collections,alex_collection_items,alex_scholarly_annotations',
    'completed',
    jsonb_build_object(
      'migration_type', 'missing_data_population',
      'tables_populated', ARRAY['alex_commentary_relationships', 'alex_research_collections', 'alex_collection_items', 'alex_scholarly_annotations'],
      'timestamp', NOW(),
      'description', 'Populated empty Alexandria tables with available data from archive structure and existing records'
    )
  );

-- ===================================================================
-- 6. VERIFICATION QUERIES
-- ===================================================================

-- Verify populated tables
DO $$
DECLARE
  relationships_count INT;
  collections_count INT;
  collection_items_count INT;
  annotations_count INT;
BEGIN
  SELECT COUNT(*) INTO relationships_count FROM alex_commentary_relationships;
  SELECT COUNT(*) INTO collections_count FROM alex_research_collections;
  SELECT COUNT(*) INTO collection_items_count FROM alex_collection_items;
  SELECT COUNT(*) INTO annotations_count FROM alex_scholarly_annotations;
  
  RAISE NOTICE 'Alexandria Missing Data Population Results:';
  RAISE NOTICE '- Commentary Relationships: % records', relationships_count;
  RAISE NOTICE '- Research Collections: % records', collections_count;
  RAISE NOTICE '- Collection Items: % records', collection_items_count;
  RAISE NOTICE '- Scholarly Annotations: % records', annotations_count;
END $$;
