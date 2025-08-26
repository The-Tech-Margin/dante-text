# Dante Text API Documentation

## Overview

This document provides comprehensive documentation for the Dante Text API endpoints that expose PostgreSQL functions for accessing both current (DDP) and historical (Alexandria Archive) commentary data.

## System Architecture

The API is built on three main data systems:

- **DDP (Digital Dante Project)** - Current active commentaries (`dde_*` tables)
- **Alexandria Archive** - Historical commentary versions (`alex_*` tables)
- **Unified Functions** - Cross-system queries that combine both datasets

## API Endpoints

### Alexandria Archive Endpoints

#### `POST /api/alexandria/compare-versions`

Compare historical versions of a specific commentary.

**Request Body:**

```typescript
{
  commentary_name: string;
}
```

**Response:**

```typescript
{
  results: Array<{
    version_id: string,
    version_source: 'current_2024' | 'alexandria_archive' | 'digitaldante_1996' | 'princeton_dante_project',
    version_identifier: string,
    text_count: number,
    date_created: string | null,
    editor_notes: string | null
  }>,
  count: number,
  commentary_name: string
}
```

#### `POST /api/alexandria/find-variants`

Find textual variants across historical versions for a specific passage.

**Request Body:**

```typescript
{
  cantica: 'inferno' | 'purgatorio' | 'paradiso' | 'general',
  canto: number,
  start_line: number,
  end_line: number
}
```

**Response:**

```typescript
{
  results: Array<{
    commentary_name: string,
    version_source: string,
    content_preview: string,
    editorial_changes: object,
    variant_notes: string | null
  }>,
  count: number,
  passage: {
    cantica: string,
    canto: number,
    start_line: number,
    end_line: number
  }
}
```

#### `POST /api/alexandria/scholarly-search`

Search across all historical and current versions with scholarly context.

**Request Body:**

```typescript
{
  search_term: string,
  include_historical?: boolean, // default: true
  version_filter?: 'current_2024' | 'alexandria_archive' | 'digitaldante_1996' | 'princeton_dante_project',
  result_limit?: number // default: 20
}
```

**Response:**

```typescript
{
  results: Array<{
    commentary_name: string,
    version_source: string,
    cantica: 'inferno' | 'purgatorio' | 'paradiso' | 'general',
    canto_id: number,
    content_match: string,
    is_historical: boolean,
    relevance_score: number
  }>,
  count: number,
  query: string,
  filters: {
    include_historical: boolean,
    version_filter?: string
  }
}
```

#### `POST /api/alexandria/commentary-network`

Analyze scholarly relationships and influence networks between commentaries.

**Request Body:**

```typescript
{
  commentary_id: string,
  max_depth?: number // default: 2
}
```

**Response:**

```typescript
{
  results: Array<{
    source_name: string,
    target_name: string,
    relationship_type: string,
    confidence_level: number,
    depth_level: number
  }>,
  count: number,
  commentary_id: string,
  max_depth: number
}
```

### DDP (Current Commentary) Endpoints

#### `POST /api/ddp/search-commentaries`

Search current active commentaries.

**Request Body:**

```typescript
{
  search_term: string,
  commentary_filter?: string,
  cantica_filter?: 'inferno' | 'purgatorio' | 'paradiso' | 'general',
  result_limit?: number // default: 20
}
```

**Response:**

```typescript
{
  results: Array<{
    commentary_name: string,
    cantica: 'inferno' | 'purgatorio' | 'paradiso' | 'general',
    canto_id: number,
    content_match: string,
    relevance_score: number,
    text_type: 'commentary' | 'poem' | 'description' | 'proemio' | 'conclusione',
    language: 'latin' | 'italian' | 'english'
  }>,
  count: number,
  query: string,
  filters: {
    commentary_filter?: string,
    cantica_filter?: string
  }
}
```

#### `POST /api/ddp/find-passages`

Find passages in current commentaries by location.

**Request Body:**

```typescript
{
  cantica: 'inferno' | 'purgatorio' | 'paradiso' | 'general',
  canto: number,
  start_line: number,
  end_line: number
}
```

**Response:**

```typescript
{
  results: Array<{
    commentary_name: string,
    content_preview: string,
    start_line: number,
    end_line: number,
    text_type: 'commentary' | 'poem' | 'description' | 'proemio' | 'conclusione',
    language: 'latin' | 'italian' | 'english'
  }>,
  count: number,
  passage: {
    cantica: string,
    canto: number,
    start_line: number,
    end_line: number
  }
}
```

#### `POST /api/ddp/commentary-stats`

Get statistics for a specific commentary.

**Request Body:**

```typescript
{
  commentary_name: string;
}
```

**Response:**

```typescript
{
  stats: {
    commentary_name: string,
    text_count: number,
    canticas_covered: string[],
    total_lines: number,
    avg_text_length: number,
    last_updated: string
  } | null,
  commentary_name: string
}
```

### Unified Cross-System Endpoints

#### `POST /api/unified/search-all-texts`

Search across both current and historical systems.

**Request Body:**

```typescript
{
  search_term: string,
  include_historical?: boolean, // default: true
  include_current?: boolean, // default: true
  commentary_filter?: string,
  result_limit?: number // default: 50
}
```

**Response:**

```typescript
{
  results: Array<{
    commentary_name: string,
    source_system: 'ddp_current' | 'alex_historical',
    version_source: string,
    cantica: 'inferno' | 'purgatorio' | 'paradiso' | 'general',
    canto_id: number,
    content_match: string,
    is_historical: boolean,
    relevance_score: number,
    start_line: number,
    end_line: number
  }>,
  count: number,
  historical_count: number,
  current_count: number,
  query: string,
  filters: {
    include_historical: boolean,
    include_current: boolean,
    commentary_filter?: string
  }
}
```

#### `POST /api/unified/compare-versions`

Compare versions across both current and historical systems.

**Request Body:**

```typescript
{
  commentary_name: string;
}
```

**Response:**

```typescript
{
  results: Array<{
    commentary_name: string,
    source_system: 'ddp_current' | 'alex_historical',
    version_source: string,
    text_count: number,
    total_lines: number,
    avg_content_length: number,
    date_info: string,
    has_variants: boolean
  }>,
  current_versions: Array<any>,
  historical_versions: Array<any>,
  commentary_name: string,
  version_count: number
}
```

#### `POST /api/unified/find-variants`

Find passage variants across both current and historical systems.

**Request Body:**

```typescript
{
  cantica: 'inferno' | 'purgatorio' | 'paradiso' | 'general',
  canto: number,
  start_line: number,
  end_line: number
}
```

**Response:**

```typescript
{
  results: Array<{
    commentary_name: string,
    source_system: 'ddp_current' | 'alex_historical',
    version_source: string,
    content_preview: string,
    start_line: number,
    end_line: number,
    editorial_changes: object,
    variant_notes: string | null,
    is_historical: boolean
  }>,
  current_variants: Array<any>,
  historical_variants: Array<any>,
  count: number,
  passage: {
    cantica: string,
    canto: number,
    start_line: number,
    end_line: number
  }
}
```

## Error Responses

All endpoints return consistent error responses:

```typescript
{
  error: string,
  details?: string
}
```

Common HTTP status codes:

- `400` - Bad Request (missing/invalid parameters)
- `405` - Method Not Allowed (non-POST requests)
- `500` - Internal Server Error (database or server issues)

## Data Types

### Enums

**cantica_type:**

- `'inferno'`
- `'purgatorio'`
- `'paradiso'`
- `'general'`

**language_type:**

- `'latin'`
- `'italian'`
- `'english'`

**text_type:**

- `'commentary'`
- `'poem'`
- `'description'`
- `'proemio'`
- `'conclusione'`

**version_source:**

- `'current_2024'`
- `'alexandria_archive'`
- `'digitaldante_1996'`
- `'princeton_dante_project'`

## Usage Examples

### Basic Commentary Search

```typescript
const response = await fetch("/api/ddp/search-commentaries", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    search_term: "beatrice",
    cantica_filter: "paradiso",
  }),
});
```

### Historical Version Comparison

```typescript
const response = await fetch("/api/alexandria/compare-versions", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    commentary_name: "Scartazzini",
  }),
});
```

### Cross-System Unified Search

```typescript
const response = await fetch("/api/unified/search-all-texts", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    search_term: "divine love",
    include_historical: true,
    include_current: true,
    result_limit: 100,
  }),
});
```

## Performance Notes

- **Caching**: Results are not cached by default. Consider implementing client-side caching for repeated queries.
- **Pagination**: Use `result_limit` parameters to control response size. Default limits are set for optimal performance.
- **Historical Search**: Alexandria Archive searches may be slower due to the dynamic SQL implementation.
- **Network Analysis**: Commentary network queries with high `max_depth` values may take longer to execute.

## Integration with React

The frontend team should create TypeScript types based on these API responses and implement React hooks or service functions to interact with these endpoints. Consider using libraries like React Query or SWR for caching and state management.
