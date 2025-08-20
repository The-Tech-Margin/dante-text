# Dante Database API Integration Guide

## 🚀 **Backend-Only Architecture**

This project provides a **complete backend infrastructure** for the Dante Commentary Platform with:
- ✅ **Supabase PostgreSQL database** with optimized schema
- ✅ **6 high-performance SQL functions** for search and analysis
- ✅ **Next.js API routes** exposing all functionality
- ✅ **Migration scripts** for Oracle → Supabase conversion

---

## 📋 **Available API Endpoints**

### **🔍 Search APIs**

#### **POST /api/search/commentaries**
Search commentaries with relevance ranking.

```typescript
// Request
{
  "search_term": "dante inferno",
  "lang_filter": "latin", // optional: "latin" | "italian" | "english"  
  "limit": 20 // optional, default: 20
}

// Response
{
  "results": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "comm_id": "13750",
      "comm_name": "benvenuto", 
      "comm_author": "Benvenuto da Imola",
      "comm_lang": "latin",
      "comm_pub_year": "1375-1380",
      "comm_biblio": "Benvenuto da Imola commentary on Dante's Divine Comedy",
      "comm_editor": "Modern Scholar Name",
      "comm_copyright": false,
      "comm_data_entry": "Digitized by Dartmouth Dante Project",
      "created_at": "2025-08-19T20:30:00Z",
      "updated_at": "2025-08-19T20:30:00Z",
      "relevance_score": 0.95
    }
  ],
  "count": 1,
  "query": "dante inferno"
}
```

#### **POST /api/search/texts**
Search text content with context.

```typescript
// Request
{
  "search_term": "beatrice",
  "commentary_ids": ["13750"], // optional filter
  "cantica_filter": "paradiso", // optional: "inferno" | "purgatorio" | "paradiso"
  "limit": 20
}

// Response
{
  "results": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "idx": 1001,
      "doc_id": "137503120010",
      "commentary_id": "550e8400-e29b-41d4-a716-446655440000",
      "commentary_name": "benvenuto",
      "cantica": "paradiso",
      "canto_id": 31,
      "start_line": 2,
      "end_line": 5,
      "text_language": "latin",
      "text_type": "commentary",
      "source_path": "Commentaries/benvenuto/para/31.e",
      "content": "Text about Beatrice...",
      "context_before": "Previous context...",
      "context_after": "Following context...",
      "created_at": "2025-08-19T20:30:00Z",
      "updated_at": "2025-08-19T20:30:00Z"
    }
  ],
  "count": 1,
  "query": "beatrice"
}
```

#### **POST /api/search/highlights**
Search with highlighted matching terms.

```typescript
// Request
{
  "search_term": "divine",
  "commentary_filter": "13750", // optional
  "limit": 15
}

// Response
{
  "results": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "idx": 1002,
      "doc_id": "137501010010", 
      "commentary_id": "550e8400-e29b-41d4-a716-446655440000",
      "commentary_name": "benvenuto",
      "cantica": "inferno",
      "canto_id": 1,
      "start_line": 1,
      "end_line": 10,
      "text_language": "latin",
      "text_type": "commentary",
      "source_path": "Commentaries/benvenuto/inf/01.e",
      "highlighted_content": "The <mark>divine</mark> comedy represents...",
      "created_at": "2025-08-19T20:30:00Z",
      "updated_at": "2025-08-19T20:30:00Z"
    }
  ],
  "count": 1,
  "query": "divine"
}
```

### **📊 Analytics APIs**

#### **GET /api/commentary/[id]/stats**
Get comprehensive commentary statistics.

```typescript
// GET /api/commentary/13750/stats

// Response
{
  "commentary_info": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "comm_id": "13750",
    "comm_name": "benvenuto",
    "comm_author": "Benvenuto da Imola",
    "comm_lang": "latin",
    "comm_pub_year": "1375-1380",
    "comm_biblio": "Benvenuto da Imola commentary on Dante's Divine Comedy",
    "comm_editor": "Modern Scholar Name",
    "comm_copyright": false,
    "comm_data_entry": "Digitized by Dartmouth Dante Project",
    "created_at": "2025-08-19T20:30:00Z",
    "updated_at": "2025-08-19T20:30:00Z"
  },
  "statistics": {
    "total_texts": 1577,
    "canticas_covered": 3,
    "cantos_covered": 100, 
    "lines_covered": 4720,
    "languages_used": ["latin"],
    "text_types_used": ["commentary", "proemio"],
    "avg_text_length": 256.4,
    "earliest_canto": 1,
    "latest_canto": 33,
    "content_distribution": {
      "inferno": 525,
      "purgatorio": 520,
      "paradiso": 532
    }
  },
  "last_updated": "2025-08-19T20:30:00Z"
}
```

### **🔄 Analysis APIs**

#### **POST /api/analysis/compare-passage**
Compare commentaries for specific passage.

```typescript
// Request
{
  "cantica": "inferno",
  "canto": 1,
  "start_line": 1,
  "end_line": 10
}

// Response
{
  "passage": {
    "cantica": "inferno",
    "canto": 1,
    "start_line": 1,
    "end_line": 10
  },
  "comparisons": [
    {
      "commentary_info": {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "comm_id": "13750",
        "comm_name": "benvenuto",
        "comm_author": "Benvenuto da Imola",
        "comm_lang": "latin",
        "comm_pub_year": "1375-1380",
        "comm_biblio": "Benvenuto da Imola commentary on Dante's Divine Comedy"
      },
      "text_segments": [
        {
          "id": "550e8400-e29b-41d4-a716-446655440003",
          "idx": 1003,
          "doc_id": "137501010010",
          "cantica": "inferno",
          "canto_id": 1,
          "start_line": 1,
          "end_line": 10,
          "text_language": "latin",
          "text_type": "commentary",
          "content": "Commentary text for lines 1-10...",
          "source_path": "Commentaries/benvenuto/inf/01.e"
        }
      ],
      "coverage_score": 0.85,
      "total_segments": 1
    }
  ],
  "count": 1
}
```

#### **GET /api/navigation/tree**
Get navigation tree for commentary structure.

```typescript
// GET /api/navigation/tree?commentary_id=13750

// Response
{
  "commentary_info": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "comm_id": "13750",
    "comm_name": "benvenuto",
    "comm_author": "Benvenuto da Imola",
    "comm_lang": "latin"
  },
  "navigation_tree": {
    "inferno": [
      {
        "canto_id": 1,
        "text_count": 15,
        "line_range": "1-136",
        "has_texts": true,
        "text_types": ["commentary", "proemio"],
        "languages": ["latin"],
        "earliest_line": 1,
        "latest_line": 136
      }
    ],
    "purgatorio": [
      {
        "canto_id": 1,
        "text_count": 12,
        "line_range": "1-136",
        "has_texts": true,
        "text_types": ["commentary"],
        "languages": ["latin"],
        "earliest_line": 1,
        "latest_line": 136
      }
    ],
    "paradiso": [
      {
        "canto_id": 1,
        "text_count": 18,
        "line_range": "1-142",
        "has_texts": true,
        "text_types": ["commentary"],
        "languages": ["latin"], 
        "earliest_line": 1,
        "latest_line": 142
      }
    ]
  },
  "total_canticas": 3,
  "total_cantos": 100,
  "total_texts": 1577
}
```

---

## 🗄️ **Supabase Functions**

All API endpoints call these optimized PostgreSQL functions:

### **Search Functions**
- `search_commentaries_ranked(search_term, lang_filter, limit_count)`
- `search_texts_with_context(search_term, commentary_ids, cantica_filter, limit_count)`  
- `search_with_highlights(search_term, commentary_filter, limit_count)`

### **Analytics Functions**
- `get_commentary_stats(input_commentary_id)`
- `compare_commentaries_by_passage(input_cantica, input_canto, input_start_line, input_end_line)`
- `get_navigation_tree(input_commentary_id)`

---

## 🔧 **Database Schema**

### **Enums**
```sql
-- Cantica types for Dante's Divine Comedy structure
CREATE TYPE cantica_type AS ENUM ('inferno', 'purgatorio', 'paradiso', 'general');

-- Language types for commentary texts
CREATE TYPE language_type AS ENUM ('latin', 'italian', 'english');

-- Text content types
CREATE TYPE text_type AS ENUM ('commentary', 'poem', 'description', 'proemio', 'conclusione');
```

### **dde_commentaries** - Commentary Metadata
```sql
CREATE TABLE public.dde_commentaries (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  comm_id VARCHAR(5) UNIQUE NOT NULL, -- Original 5-char ID for compatibility
  comm_name VARCHAR(64) NOT NULL, -- Directory name
  comm_author VARCHAR(256) NOT NULL, -- Full author name
  comm_lang language_type NOT NULL, -- Primary language of commentary
  comm_pub_year VARCHAR(256), -- Publication year or range
  comm_biblio TEXT, -- Bibliographic information
  comm_editor VARCHAR(256), -- Modern editor information
  comm_copyright BOOLEAN DEFAULT false, -- Copyright status
  comm_data_entry TEXT, -- Data entry notes/credits
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()) NOT NULL
);
```

### **dde_texts** - Text Content  
```sql
CREATE TABLE public.dde_texts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  idx BIGSERIAL, -- Auto-incrementing for uniqueness (added in migration)
  doc_id VARCHAR(12) NOT NULL, -- Original 12-char ID for compatibility
  commentary_id UUID REFERENCES public.dde_commentaries(id) ON DELETE CASCADE,
  cantica cantica_type NOT NULL, -- Which part of Divine Comedy
  canto_id INTEGER CHECK (canto_id >= 0 AND canto_id <= 34), -- Canto number
  start_line INTEGER CHECK (start_line >= 0), -- Starting line reference
  end_line INTEGER CHECK (end_line >= 0), -- Ending line reference
  text_language language_type NOT NULL, -- Language of this text segment
  text_type text_type NOT NULL, -- Type of content
  source_path VARCHAR(128), -- Original file path reference
  content TEXT NOT NULL, -- The actual commentary text
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()) NOT NULL
);
```

### **Indexes for Performance**
```sql
-- Commentary indexes
CREATE INDEX idx_dde_commentaries_comm_id ON public.dde_commentaries(comm_id);
CREATE INDEX idx_dde_commentaries_comm_name ON public.dde_commentaries(comm_name);

-- Text indexes
CREATE INDEX idx_dde_texts_doc_id ON public.dde_texts(doc_id);
CREATE INDEX idx_dde_texts_commentary_id ON public.dde_texts(commentary_id);
CREATE INDEX idx_dde_texts_cantica_canto ON public.dde_texts(cantica, canto_id);

-- Full-text search index
CREATE INDEX idx_dde_texts_content_gin ON public.dde_texts 
  USING gin(to_tsvector('english', content));
```

---

## 🚦 **Current Status**

### **✅ Completed**
- Database schema with optimized indexes
- 6 SQL functions deployed and tested
- **6/6 API routes implemented** ✅
- Migration scripts ready
- **Complete integration guide** ✅

### **⚠️ Pending**
- [ ] Apply schema migration (add `idx` column)
- [ ] Complete data migration (74+ commentaries)
- [ ] Validate with real data

### **✅ All API Routes Implemented**
- `/api/search/commentaries` ✅
- `/api/search/texts` ✅  
- `/api/search/highlights` ✅
- `/api/commentary/[id]/stats` ✅
- `/api/analysis/compare-passage` ✅
- `/api/navigation/tree` ✅

---

## 🔌 **Next.js 15 App Router Integration**

### **🚀 Project Setup**

#### **1. Create Next.js 15 App Router Project**
```bash
npx create-next-app@latest dante-frontend --typescript --tailwind --eslint --app --src-dir
cd dante-frontend
npm install @supabase/supabase-js
```

#### **2. Vercel Environment Variables**
Configure in your Vercel dashboard or `.env.local`:

```bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Optional: If using separate backend
NEXT_PUBLIC_API_BASE_URL=https://your-backend.vercel.app
```

#### **3. Supabase Client Setup**
```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

### **📱 App Router Components**

#### **Server Component (Direct Supabase)**
```typescript
// app/search/page.tsx
import { supabase } from '@/lib/supabase'
import { SearchResults } from '@/components/SearchResults'

interface SearchParams {
  q?: string
  lang?: string
}

export default async function SearchPage({ 
  searchParams 
}: { 
  searchParams: SearchParams 
}) {
  const query = searchParams.q || ''
  
  if (!query) {
    return <div>Enter a search term</div>
  }

  // Direct Supabase call in server component
  const { data: commentaries } = await supabase.rpc('search_commentaries_ranked', {
    search_term: query,
    lang_filter: searchParams.lang || null,
    limit_count: 20
  })

  return (
    <div>
      <h1>Search Results for "{query}"</h1>
      <SearchResults results={commentaries || []} />
    </div>
  )
}
```

#### **Client Component (API Routes)**
```typescript
// app/components/SearchForm.tsx
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'

export default function SearchForm() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const [loading, setLoading] = useState(false)
  const router = useRouter()

  const searchCommentaries = async (term: string) => {
    setLoading(true)
    try {
      const response = await fetch('/api/search/commentaries', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ search_term: term, limit: 20 })
      })
      const data = await response.json()
      setResults(data.results)
    } catch (error) {
      console.error('Search failed:', error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-4">
      <div className="flex gap-2">
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search commentaries..."
          className="flex-1 px-4 py-2 border rounded-lg"
        />
        <button 
          onClick={() => searchCommentaries(query)}
          disabled={loading}
          className="px-6 py-2 bg-blue-600 text-white rounded-lg disabled:opacity-50"
        >
          {loading ? 'Searching...' : 'Search'}
        </button>
      </div>
      
      {results.length > 0 && (
        <div className="grid gap-4">
          {results.map((result: any) => (
            <div key={result.comm_id} className="p-4 border rounded-lg">
              <h3 className="font-semibold">{result.comm_name}</h3>
              <p className="text-gray-600">{result.comm_author}</p>
              <span className="text-sm bg-gray-100 px-2 py-1 rounded">
                {result.comm_lang}
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
```

#### **Commentary Detail Page**
```typescript
// app/commentary/[id]/page.tsx
import { supabase } from '@/lib/supabase'
import { CommentaryStats } from '@/components/CommentaryStats'
import { NavigationTree } from '@/components/NavigationTree'

export default async function CommentaryPage({ 
  params 
}: { 
  params: { id: string } 
}) {
  const commentaryId = params.id

  // Parallel data fetching
  const [statsResult, treeResult] = await Promise.all([
    supabase.rpc('get_commentary_stats', { input_commentary_id: commentaryId }),
    supabase.rpc('get_navigation_tree', { input_commentary_id: commentaryId })
  ])

  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div className="lg:col-span-2">
        <h1>Commentary {commentaryId}</h1>
        <CommentaryStats stats={statsResult.data} />
      </div>
      
      <div>
        <NavigationTree tree={treeResult.data} />
      </div>
    </div>
  )
}
```

#### **Passage Comparison Hook**
```typescript
// hooks/usePassageComparison.ts
'use client'

import { useState } from 'react'

interface PassageParams {
  cantica: 'inferno' | 'purgatorio' | 'paradiso'
  canto: number
  start_line: number
  end_line: number
}

export function usePassageComparison() {
  const [comparisons, setComparisons] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const comparePassage = async (params: PassageParams) => {
    setLoading(true)
    setError(null)

    try {
      const response = await fetch('/api/analysis/compare-passage', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(params)
      })

      if (!response.ok) {
        throw new Error('Comparison failed')
      }

      const data = await response.json()
      setComparisons(data.comparisons)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    } finally {
      setLoading(false)
    }
  }

  return { comparisons, loading, error, comparePassage }
}
```

### **🚀 Vercel Deployment Configuration**

#### **vercel.json**
```json
{
  "functions": {
    "app/api/**/*.ts": {
      "maxDuration": 30
    }
  },
  "env": {
    "NEXT_PUBLIC_SUPABASE_URL": "@supabase_url",
    "NEXT_PUBLIC_SUPABASE_ANON_KEY": "@supabase_anon_key"
  }
}
```

#### **Deployment Commands**
```bash
# Install Vercel CLI
npm i -g vercel

# Set environment variables
vercel env add NEXT_PUBLIC_SUPABASE_URL
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY
vercel env add SUPABASE_SERVICE_ROLE_KEY

# Deploy
vercel --prod
```

#### **Environment Variable Management**
```bash
# Development
vercel env pull .env.local

# Production secrets
vercel env add SUPABASE_SERVICE_ROLE_KEY production
vercel env add NEXT_PUBLIC_SUPABASE_URL production
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production
```

### **🎯 Performance Optimizations**

#### **App Router Data Fetching Patterns**
```typescript
// Server Components (SSR)
export default async function ServerPage() {
  // Direct Supabase calls - no API routes needed
  const { data } = await supabase.rpc('search_commentaries_ranked', {...})
  return <Results data={data} />
}

// Client Components (CSR)  
export default function ClientPage() {
  // Use API routes for client-side requests
  const { data } = useSWR('/api/search/commentaries', fetcher)
  return <Results data={data} />
}

// Static Generation (SSG)
export async function generateStaticParams() {
  const { data: commentaries } = await supabase
    .from('dde_commentaries')
    .select('comm_id')
  
  return commentaries?.map(c => ({ id: c.comm_id })) || []
}
```

### **🔧 TypeScript Definitions**
```typescript
// types/dante.ts

// Enum types
export type CanticaType = 'inferno' | 'purgatorio' | 'paradiso' | 'general'
export type LanguageType = 'latin' | 'italian' | 'english'
export type TextType = 'commentary' | 'poem' | 'description' | 'proemio' | 'conclusione'

// Commentary interface - complete database model
export interface Commentary {
  id: string // UUID
  comm_id: string // 5-character ID for compatibility
  comm_name: string // Directory name
  comm_author: string // Full author name
  comm_lang: LanguageType // Primary language
  comm_pub_year?: string // Publication year or range
  comm_biblio?: string // Bibliographic information
  comm_editor?: string // Modern editor information
  comm_copyright: boolean // Copyright status
  comm_data_entry?: string // Data entry notes/credits
  created_at: string // ISO timestamp
  updated_at: string // ISO timestamp
  relevance_score?: number // Only in search results
}

// Text result interface - complete database model
export interface TextResult {
  id: string // UUID
  idx: number // Auto-incrementing unique ID
  doc_id: string // 12-character original ID
  commentary_id: string // UUID reference
  commentary_name?: string // Joined from commentary table
  cantica: CanticaType // Which part of Divine Comedy
  canto_id: number // Canto number (0-34)
  start_line: number // Starting line reference
  end_line: number // Ending line reference
  text_language: LanguageType // Language of this text segment
  text_type: TextType // Type of content
  source_path?: string // Original file path reference
  content: string // The actual commentary text
  created_at: string // ISO timestamp
  updated_at: string // ISO timestamp
  // Search-specific fields
  context_before?: string // Previous context for search results
  context_after?: string // Following context for search results
  highlighted_content?: string // Content with search terms highlighted
}

// Navigation node interface
export interface NavigationNode {
  canto_id: number
  text_count: number
  line_range: string
  has_texts: boolean
  text_types: TextType[]
  languages: LanguageType[]
  earliest_line: number
  latest_line: number
}

// Navigation tree interface
export interface NavigationTree {
  commentary_info: {
    id: string
    comm_id: string
    comm_name: string
    comm_author: string
    comm_lang: LanguageType
  }
  navigation_tree: {
    inferno?: NavigationNode[]
    purgatorio?: NavigationNode[]
    paradiso?: NavigationNode[]
  }
  total_canticas: number
  total_cantos: number
  total_texts: number
}

// Commentary statistics interface
export interface CommentaryStats {
  commentary_info: Commentary
  statistics: {
    total_texts: number
    canticas_covered: number
    cantos_covered: number
    lines_covered: number
    languages_used: LanguageType[]
    text_types_used: TextType[]
    avg_text_length: number
    earliest_canto: number
    latest_canto: number
    content_distribution: {
      inferno: number
      purgatorio: number
      paradiso: number
    }
  }
  last_updated: string
}

// Passage comparison interface
export interface PassageComparison {
  commentary_info: Partial<Commentary>
  text_segments: TextResult[]
  coverage_score: number
  total_segments: number
}
```

### **cURL Examples**
```bash
# Search commentaries
curl -X POST https://your-app.vercel.app/api/search/commentaries \
  -H "Content-Type: application/json" \
  -d '{"search_term": "dante", "limit": 10}'

# Get commentary stats  
curl https://your-app.vercel.app/api/commentary/13750/stats

# Compare passage
curl -X POST https://your-app.vercel.app/api/analysis/compare-passage \
  -H "Content-Type: application/json" \
  -d '{"cantica": "inferno", "canto": 1, "start_line": 1, "end_line": 10}'
```

---

## 📚 **Migration Status**

### **Oracle → Supabase Conversion**
- **Source**: 74+ commentaries in `.e` format
- **Target**: PostgreSQL with modern schema
- **Preservation**: Original `doc_id` format maintained
- **Enhancement**: Auto-incrementing `idx` for reliability

### **Data Migration Scripts**
```bash
# Clear existing data
node scripts/clear-database.js

# Run full migration  
node scripts/migrate-commentaries.js

# Validate results
node scripts/test-functions.js
```

---

## 🎯 **Next Steps for Integration**

1. **Complete Backend** (Current Priority)
   - Apply schema migration
   - Run data migration 
   - Implement missing API routes

2. **Frontend Development** (Future)
   - Build UI components using API endpoints
   - Implement search interface
   - Add navigation and comparison tools

3. **Deployment** (Future)
   - Deploy to Vercel/Netlify
   - Configure production Supabase
   - Set up monitoring and analytics

This backend provides a **complete API foundation** for building modern Dante scholarship applications with high-performance search and analysis capabilities.