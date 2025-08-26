# TypeScript Reference Types for Frontend Team

## Overview

These are reference TypeScript types for the Dante Text API responses. The frontend team should adapt these as needed for their specific implementation.

## Core Data Types

```typescript
// Database enum types
export type CanticaType = "inferno" | "purgatorio" | "paradiso" | "general";
export type LanguageType = "latin" | "italian" | "english";
export type TextType =
  | "commentary"
  | "poem"
  | "description"
  | "proemio"
  | "conclusione";
export type VersionSource =
  | "current_2024"
  | "alexandria_archive"
  | "digitaldante_1996"
  | "princeton_dante_project";
export type SourceSystem = "ddp_current" | "alex_historical";

// Common response wrapper
export interface ApiResponse<T> {
  results: T[];
  count: number;
  error?: string;
  details?: string;
}

// Passage location reference
export interface PassageLocation {
  cantica: CanticaType;
  canto: number;
  start_line: number;
  end_line: number;
}
```

## Alexandria Archive Types

```typescript
// Commentary version comparison
export interface AlexCommentaryVersion {
  version_id: string;
  version_source: VersionSource;
  version_identifier: string;
  text_count: number;
  date_created: string | null;
  editor_notes: string | null;
}

export interface CompareVersionsResponse
  extends ApiResponse<AlexCommentaryVersion> {
  commentary_name: string;
}

// Passage variants
export interface AlexPassageVariant {
  commentary_name: string;
  version_source: string;
  content_preview: string;
  editorial_changes: Record<string, any>;
  variant_notes: string | null;
}

export interface FindVariantsResponse extends ApiResponse<AlexPassageVariant> {
  passage: PassageLocation;
}

// Scholarly search
export interface AlexScholarlyResult {
  commentary_name: string;
  version_source: string;
  cantica: CanticaType;
  canto_id: number;
  content_match: string;
  is_historical: boolean;
  relevance_score: number;
}

export interface ScholarlySearchResponse
  extends ApiResponse<AlexScholarlyResult> {
  query: string;
  filters: {
    include_historical: boolean;
    version_filter?: string;
  };
}

// Commentary network
export interface CommentaryNetworkNode {
  source_name: string;
  target_name: string;
  relationship_type: string;
  confidence_level: number;
  depth_level: number;
}

export interface CommentaryNetworkResponse
  extends ApiResponse<CommentaryNetworkNode> {
  commentary_id: string;
  max_depth: number;
}
```

## DDP (Current Commentary) Types

```typescript
// Commentary search
export interface DDPCommentaryResult {
  commentary_name: string;
  cantica: CanticaType;
  canto_id: number;
  content_match: string;
  relevance_score: number;
  text_type: TextType;
  language: LanguageType;
}

export interface DDPSearchResponse extends ApiResponse<DDPCommentaryResult> {
  query: string;
  filters: {
    commentary_filter?: string;
    cantica_filter?: string;
  };
}

// Find passages
export interface DDPPassage {
  commentary_name: string;
  content_preview: string;
  start_line: number;
  end_line: number;
  text_type: TextType;
  language: LanguageType;
}

export interface DDPFindPassagesResponse extends ApiResponse<DDPPassage> {
  passage: PassageLocation;
}

// Commentary statistics
export interface CommentaryStats {
  commentary_name: string;
  text_count: number;
  canticas_covered: string[];
  total_lines: number;
  avg_text_length: number;
  last_updated: string;
}

export interface CommentaryStatsResponse {
  stats: CommentaryStats | null;
  commentary_name: string;
  error?: string;
  details?: string;
}
```

## Unified Cross-System Types

```typescript
// Unified search result
export interface UnifiedSearchResult {
  commentary_name: string;
  source_system: SourceSystem;
  version_source: string;
  cantica: CanticaType;
  canto_id: number;
  content_match: string;
  is_historical: boolean;
  relevance_score: number;
  start_line: number;
  end_line: number;
}

export interface UnifiedSearchResponse
  extends ApiResponse<UnifiedSearchResult> {
  historical_count: number;
  current_count: number;
  query: string;
  filters: {
    include_historical: boolean;
    include_current: boolean;
    commentary_filter?: string;
  };
}

// Unified version comparison
export interface UnifiedVersionComparison {
  commentary_name: string;
  source_system: SourceSystem;
  version_source: string;
  text_count: number;
  total_lines: number;
  avg_content_length: number;
  date_info: string;
  has_variants: boolean;
}

export interface UnifiedCompareResponse
  extends ApiResponse<UnifiedVersionComparison> {
  current_versions: UnifiedVersionComparison[];
  historical_versions: UnifiedVersionComparison[];
  commentary_name: string;
  version_count: number;
}

// Unified passage variants
export interface UnifiedPassageVariant {
  commentary_name: string;
  source_system: SourceSystem;
  version_source: string;
  content_preview: string;
  start_line: number;
  end_line: number;
  editorial_changes: Record<string, any>;
  variant_notes: string | null;
  is_historical: boolean;
}

export interface UnifiedVariantsResponse
  extends ApiResponse<UnifiedPassageVariant> {
  current_variants: UnifiedPassageVariant[];
  historical_variants: UnifiedPassageVariant[];
  passage: PassageLocation;
}
```

## Request Types

```typescript
// Alexandria requests
export interface CompareVersionsRequest {
  commentary_name: string;
}

export interface FindVariantsRequest {
  cantica: CanticaType;
  canto: number;
  start_line: number;
  end_line: number;
}

export interface ScholarlySearchRequest {
  search_term: string;
  include_historical?: boolean;
  version_filter?: VersionSource;
  result_limit?: number;
}

export interface CommentaryNetworkRequest {
  commentary_id: string;
  max_depth?: number;
}

// DDP requests
export interface DDPSearchRequest {
  search_term: string;
  commentary_filter?: string;
  cantica_filter?: CanticaType;
  result_limit?: number;
}

export interface DDPFindPassagesRequest {
  cantica: CanticaType;
  canto: number;
  start_line: number;
  end_line: number;
}

export interface DDPCommentaryStatsRequest {
  commentary_name: string;
}

// Unified requests
export interface UnifiedSearchRequest {
  search_term: string;
  include_historical?: boolean;
  include_current?: boolean;
  commentary_filter?: string;
  result_limit?: number;
}

export interface UnifiedCompareVersionsRequest {
  commentary_name: string;
}

export interface UnifiedFindVariantsRequest {
  cantica: CanticaType;
  canto: number;
  start_line: number;
  end_line: number;
}
```

## Usage Examples for React Components

```typescript
// Example hook for commentary search
export const useCommentarySearch = () => {
  const [results, setResults] = useState<DDPSearchResponse | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const search = async (request: DDPSearchRequest) => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch("/api/ddp/search-commentaries", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(request),
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      const data: DDPSearchResponse = await response.json();
      setResults(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unknown error");
    } finally {
      setLoading(false);
    }
  };

  return { results, loading, error, search };
};

// Example service function for unified search
export const unifiedSearchService = {
  searchAllTexts: async (
    request: UnifiedSearchRequest
  ): Promise<UnifiedSearchResponse> => {
    const response = await fetch("/api/unified/search-all-texts", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(request),
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.error || `HTTP ${response.status}`);
    }

    return response.json();
  },
};
```

## Notes for Frontend Implementation

1. **Error Handling**: All API responses may include `error` and `details` fields. Always check for these.

2. **Loading States**: Most queries can take 1-5 seconds, especially historical searches. Implement proper loading indicators.

3. **Result Limits**: Default limits are set for performance. Implement pagination or "load more" functionality for large result sets.

4. **Type Guards**: Consider implementing type guards for runtime type checking:

```typescript
export const isUnifiedSearchResult = (obj: any): obj is UnifiedSearchResult => {
  return (
    obj &&
    typeof obj.commentary_name === "string" &&
    typeof obj.source_system === "string" &&
    typeof obj.is_historical === "boolean"
  );
};
```

5. **Caching**: Consider using React Query, SWR, or similar for caching expensive queries, especially for commentary statistics and network analysis.
