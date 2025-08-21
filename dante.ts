// types/dante.ts

// Enum types
export type CanticaType = 'inferno' | 'purgatorio' | 'paradiso' | 'general';
export type LanguageType = 'latin' | 'italian' | 'english';
export type TextType = 'commentary' | 'poem' | 'description' | 'proemio' | 'conclusione';

// Commentary interface - complete database model
export interface Commentary {
  id: string; // UUID
  comm_id: string; // 5-character ID for compatibility
  comm_name: string; // Directory name
  comm_author: string; // Full author name
  comm_lang: LanguageType; // Primary language
  comm_pub_year?: string; // Publication year or range
  comm_biblio?: string; // Bibliographic information
  comm_editor?: string; // Modern editor information
  comm_copyright: boolean; // Copyright status
  comm_data_entry?: string; // Data entry notes/credits
  created_at: string; // ISO timestamp
  updated_at: string; // ISO timestamp
  relevance_score?: number; // Only in search results
}

// Text result interface - complete database model
export interface TextResult {
  id: string; // UUID
  idx: number; // Auto-incrementing unique ID
  doc_id: string; // 12-character original ID
  commentary_id: string; // UUID reference
  commentary_name?: string; // Joined from commentary table
  cantica: CanticaType; // Which part of Divine Comedy
  canto_id: number; // Canto number (0-34)
  start_line: number; // Starting line reference
  end_line: number; // Ending line reference
  text_language: LanguageType; // Language of this text segment
  text_type: TextType; // Type of content
  source_path?: string; // Original file path reference
  content: string; // The actual commentary text
  created_at: string; // ISO timestamp
  updated_at: string; // ISO timestamp
  // Search-specific fields
  context_before?: string; // Previous context for search results
  context_after?: string; // Following context for search results
  highlighted_content?: string; // Content with search terms highlighted
}

// Navigation node interface
export interface NavigationNode {
  canto_id: number;
  text_count: number;
  line_range: string;
  has_texts: boolean;
  text_types: TextType[];
  languages: LanguageType[];
  earliest_line: number;
  latest_line: number;
}

// Navigation tree interface
export interface NavigationTree {
  commentary_info: {
    id: string;
    comm_id: string;
    comm_name: string;
    comm_author: string;
    comm_lang: LanguageType;
  };
  navigation_tree: {
    inferno?: NavigationNode[];
    purgatorio?: NavigationNode[];
    paradiso?: NavigationNode[];
  };
  total_canticas: number;
  total_cantos: number;
  total_texts: number;
}

// Commentary statistics interface
export interface CommentaryStats {
  commentary_info: Commentary;
  statistics: {
    total_texts: number;
    canticas_covered: number;
    cantos_covered: number;
    lines_covered: number;
    languages_used: LanguageType[];
    text_types_used: TextType[];
    avg_text_length: number;
    earliest_canto: number;
    latest_canto: number;
    content_distribution: {
      inferno: number;
      purgatorio: number;
      paradiso: number;
    };
  };
  last_updated: string;
}

// Passage comparison interface (for one commentary)
export interface PassageComparison {
  commentary_info: Partial<Commentary>;
  text_segments: TextResult[];
  coverage_score: number;
  total_segments: number;
}

// Full response for the passage comparison API endpoint
export interface PassageComparisonResponse {
  passage: {
    cantica: CanticaType;
    canto: number;
    start_line: number;
    end_line: number;
  };
  comparisons: PassageComparison[];
  count: number;
}

  comparisons: PassageComparison[];
  count: number;
}

// --- API Response Wrapper Types ---

// For POST /api/search/commentaries
export interface CommentarySearchResponse {
  results: Commentary[];
  count: number;
  query: string;
}

// For POST /api/search/texts
export interface TextSearchResponse {
  results: TextResult[];
  count: number;
  query: string;
}

// For POST /api/search/highlights
export interface HighlightSearchResponse {
  results: Pick<TextResult, 'id' | 'idx' | 'doc_id' | 'commentary_id' | 'commentary_name' | 'cantica' | 'canto_id' | 'start_line' | 'end_line' | 'text_language' | 'text_type' | 'source_path' | 'highlighted_content' | 'created_at' | 'updated_at'>[];
  count: number;
  query: string;
}

// types/alexandria.ts

import type { CanticaType, LanguageType, TextType, Commentary, TextResult } from './dante';

export type VersionSource = 'original_1991' | 'post_1991' | 'current_2024' | 'alexandria_archive' | 'unknown';
export type EditorialStatus = 'published' | 'draft' | 'revision' | 'archived' | 'fragment';

export interface AlexandriaCommentaryVersion {
  id: string;
  base_commentary_id: string;
  version_identifier: string;
  version_source: VersionSource;
  editorial_status: EditorialStatus;
  date_created?: string;
  date_archived?: string;
  editor_notes?: string;
  provenance_info?: Record<string, any>;
  file_path?: string;
  created_at: string;
}

export interface AlexandriaHistoricalText {
  id: string;
  commentary_version_id?: string;
  base_commentary_id?: string; // Foreign key link to dde_commentaries.id
  commentary_name: string; // Logical link to dde_commentaries.comm_name
  cantica: CanticaType;
  canto_id: number;
  start_line: number;
  end_line: number;
  content: string;
  text_type: TextType;
  text_language: LanguageType;
  version_source: VersionSource; // Now required field
  original_file_path?: string;
  variant_notes?: string;
  editorial_changes?: Record<string, any>;
  original_encoding?: string;
  modern_equivalent_found: boolean;
  similarity_score?: number;
  created_at: string;
}

export interface CommentaryTimeline {
  current: {
    id: string;
    comm_name: string;
    comm_author: string;
    comm_lang: LanguageType;
    comm_biblio?: string;
    is_historical: false;
    version_source: 'current_2024';
    created_at: string;
  } | null;
  historical: Array<{
    id: string;
    comm_name: string;
    comm_author: string;
    comm_lang: LanguageType;
    bibliography: string;
    is_historical: true;
    version_source: VersionSource;
    created_at: string;
  }>;
  textCounts: Record<string, number>;
}

export interface EmbeddedCommentaryText extends TextResult {
  dde_commentaries: Partial<Commentary>;
}

export interface PassageVariant {
  commentary_name: string;
  version_source: VersionSource;
  content_preview: string;
  editorial_changes?: Record<string, any>;
  variant_notes?: string;
}

export interface CrossVersionSearchResult {
  commentary_name: string;
  version_source: VersionSource;
  cantica: CanticaType;
  canto_id: number;
  content_match: string;
  is_historical: boolean;
  relevance_score: number;
}

export interface QueryConfig {
  includeHistorical?: boolean;
  versionFilter?: VersionSource;
  timeRange?: { start?: Date; end?: Date };
  languages?: LanguageType[];
  canticas?: CanticaType[];
  limit?: number;
  offset?: number;
}

export interface AlexandriaSearchResponse {
  results: CrossVersionSearchResult[];
  count: number;
  query: string;
  config: QueryConfig;
}