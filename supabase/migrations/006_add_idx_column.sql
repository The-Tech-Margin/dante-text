-- Fix doc_id uniqueness issue by removing constraint and adding auto-incrementing column
-- Keep doc_id for compatibility but remove unique constraint

-- Drop existing unique constraint on doc_id
ALTER TABLE dde_texts DROP CONSTRAINT IF EXISTS dde_texts_doc_id_key;

-- Drop existing primary key constraint 
ALTER TABLE dde_texts DROP CONSTRAINT IF EXISTS dde_texts_pkey;

-- Add auto-incrementing idx column as new primary key
ALTER TABLE dde_texts ADD COLUMN idx BIGSERIAL PRIMARY KEY;

-- Add index on doc_id for query performance (no longer unique)
CREATE INDEX IF NOT EXISTS idx_dde_texts_doc_id ON dde_texts(doc_id);

-- Add comment explaining the change
COMMENT ON COLUMN dde_texts.idx IS 'Auto-incrementing primary key for guaranteed uniqueness';
COMMENT ON COLUMN dde_texts.doc_id IS 'Original 12-character doc_id preserved for compatibility (no longer unique)';
