# Frontend Implementation Guide - Next.js React Hooks

## 🚀 **Backend Ready Status**
- ✅ **78 Commentaries** migrated and validated
- ✅ **6 Supabase Functions** deployed and tested
- ✅ **Complete API** routes available
- ✅ **TheTechMargin branding** specifications ready

---

## **1. Setup & Environment**

### **Dependencies**
```bash
npm install @supabase/supabase-js
npm install @supabase/auth-ui-react
npm install @supabase/auth-ui-shared
```

### **Environment Variables (.env.local)**
```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### **Supabase Client Setup**
```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Types
export interface Commentary {
  id: string
  comm_name: string
  comm_author: string
  comm_lang: 'italian' | 'latin' | 'english'
  bibliography: string
  created_at: string
}

export interface TextSegment {
  id: string
  commentary_id: string
  cantica: 'inferno' | 'purgatorio' | 'paradiso'
  canto_id: number
  start_line: number
  end_line: number
  content: string
  text_type: 'commentary' | 'poem_text'
}
```

---

## **2. Core React Hooks**

### **Search Hooks**

```typescript
// hooks/useCommentarySearch.ts
import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'

interface SearchResult {
  id: string
  comm_name: string
  comm_author: string
  comm_lang: string
  bibliography: string
  relevance_score: number
}

export function useCommentarySearch() {
  const [results, setResults] = useState<SearchResult[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const searchCommentaries = async (
    searchTerm: string,
    langFilter?: string,
    limit: number = 20
  ) => {
    setLoading(true)
    setError(null)
    
    try {
      const { data, error } = await supabase.rpc('search_commentaries_ranked', {
        search_term: searchTerm,
        lang_filter: langFilter,
        limit_count: limit
      })

      if (error) throw error
      setResults(data || [])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Search failed')
      setResults([])
    } finally {
      setLoading(false)
    }
  }

  return { results, loading, error, searchCommentaries }
}
```

```typescript
// hooks/useTextSearch.ts
import { useState } from 'react'
import { supabase } from '@/lib/supabase'

interface TextSearchResult {
  id: string
  commentary_name: string
  cantica: string
  canto_id: number
  context: string
  relevance_score: number
}

export function useTextSearch() {
  const [results, setResults] = useState<TextSearchResult[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const searchTexts = async (
    searchTerm: string,
    cantica?: string,
    limit: number = 50
  ) => {
    setLoading(true)
    setError(null)
    
    try {
      const { data, error } = await supabase.rpc('search_texts_with_context', {
        search_term: searchTerm,
        cantica_filter: cantica,
        limit_count: limit
      })

      if (error) throw error
      setResults(data || [])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Text search failed')
      setResults([])
    } finally {
      setLoading(false)
    }
  }

  return { results, loading, error, searchTexts }
}
```

```typescript
// hooks/useHighlightSearch.ts
import { useState } from 'react'
import { supabase } from '@/lib/supabase'

interface HighlightResult {
  id: string
  commentary_name: string
  cantica: string
  canto_id: number
  highlighted_content: string
  relevance_score: number
}

export function useHighlightSearch() {
  const [results, setResults] = useState<HighlightResult[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const searchWithHighlights = async (
    searchTerm: string,
    limit: number = 30
  ) => {
    setLoading(true)
    setError(null)
    
    try {
      const { data, error } = await supabase.rpc('search_with_highlights', {
        search_term: searchTerm,
        limit_count: limit
      })

      if (error) throw error
      setResults(data || [])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Highlight search failed')
      setResults([])
    } finally {
      setLoading(false)
    }
  }

  return { results, loading, error, searchWithHighlights }
}
```

### **Commentary Analysis Hooks**

```typescript
// hooks/useCommentaryStats.ts
import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'

interface CommentaryStats {
  total_texts: number
  canticas_covered: number
  cantos_covered: number
  lines_covered: number
  languages_used: string[]
  text_types_used: string[]
  avg_text_length: number
  last_updated: string
}

export function useCommentaryStats(commentaryId: string | null) {
  const [stats, setStats] = useState<CommentaryStats | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!commentaryId) return

    const fetchStats = async () => {
      setLoading(true)
      setError(null)
      
      try {
        const { data, error } = await supabase.rpc('get_commentary_stats', {
          input_commentary_id: commentaryId
        })

        if (error) throw error
        setStats(data?.[0] || null)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to load stats')
        setStats(null)
      } finally {
        setLoading(false)
      }
    }

    fetchStats()
  }, [commentaryId])

  return { stats, loading, error }
}
```

```typescript
// hooks/usePassageComparison.ts
import { useState } from 'react'
import { supabase } from '@/lib/supabase'

interface PassageComparison {
  id: string
  comm_name: string
  comm_author: string
  comm_lang: string
  content_preview: string
  coverage_score: number
}

export function usePassageComparison() {
  const [comparisons, setComparisons] = useState<PassageComparison[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const comparePassage = async (
    cantica: 'inferno' | 'purgatorio' | 'paradiso',
    canto: number,
    startLine: number,
    endLine: number
  ) => {
    setLoading(true)
    setError(null)
    
    try {
      const { data, error } = await supabase.rpc('compare_commentaries_by_passage', {
        input_cantica: cantica,
        input_canto: canto,
        input_start_line: startLine,
        input_end_line: endLine
      })

      if (error) throw error
      setComparisons(data || [])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Comparison failed')
      setComparisons([])
    } finally {
      setLoading(false)
    }
  }

  return { comparisons, loading, error, comparePassage }
}
```

### **Navigation Hook**

```typescript
// hooks/useNavigationTree.ts
import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'

interface NavigationNode {
  cantica: 'inferno' | 'purgatorio' | 'paradiso'
  canto_id: number
  text_count: number
  line_range: string
  has_texts: boolean
}

export function useNavigationTree(commentaryId?: string) {
  const [nodes, setNodes] = useState<NavigationNode[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchNavigation = async () => {
      setLoading(true)
      setError(null)
      
      try {
        const { data, error } = await supabase.rpc('get_navigation_tree', {
          commentary_id: commentaryId || null
        })

        if (error) throw error
        setNodes(data || [])
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Navigation load failed')
        setNodes([])
      } finally {
        setLoading(false)
      }
    }

    fetchNavigation()
  }, [commentaryId])

  return { nodes, loading, error }
}
```

### **Commentary Management Hook**

```typescript
// hooks/useCommentaries.ts
import { useState, useEffect } from 'react'
import { supabase, Commentary } from '@/lib/supabase'

export function useCommentaries() {
  const [commentaries, setCommentaries] = useState<Commentary[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchCommentaries = async () => {
    setLoading(true)
    setError(null)
    
    try {
      const { data, error } = await supabase
        .from('dde_commentaries')
        .select('*')
        .order('comm_name')

      if (error) throw error
      setCommentaries(data || [])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load commentaries')
      setCommentaries([])
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchCommentaries()
  }, [])

  const refetch = fetchCommentaries

  return { commentaries, loading, error, refetch }
}
```

---

## **3. Usage Examples**

### **Search Component Example**
```typescript
// components/CommentarySearch.tsx
import { useState } from 'react'
import { useCommentarySearch } from '@/hooks/useCommentarySearch'

export function CommentarySearch() {
  const [searchTerm, setSearchTerm] = useState('')
  const [langFilter, setLangFilter] = useState<string>('')
  const { results, loading, error, searchCommentaries } = useCommentarySearch()

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault()
    if (searchTerm.trim()) {
      await searchCommentaries(searchTerm, langFilter || undefined)
    }
  }

  return (
    <div className="bg-gray-900 text-green-400 p-6 rounded-lg border border-green-500/20">
      <form onSubmit={handleSearch} className="mb-6">
        <div className="flex gap-4 mb-4">
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="Search commentaries..."
            className="flex-1 bg-gray-800 text-green-400 border border-green-500/30 rounded px-4 py-2 placeholder:text-green-400/60"
          />
          <select
            value={langFilter}
            onChange={(e) => setLangFilter(e.target.value)}
            className="bg-gray-800 text-green-400 border border-green-500/30 rounded px-4 py-2"
          >
            <option value="">All Languages</option>
            <option value="italian">Italian</option>
            <option value="latin">Latin</option>
            <option value="english">English</option>
          </select>
          <button
            type="submit"
            disabled={loading}
            className="bg-green-600 hover:bg-green-700 disabled:bg-gray-600 text-white px-6 py-2 rounded"
          >
            {loading ? 'Searching...' : 'Search'}
          </button>
        </div>
      </form>

      {error && (
        <div className="bg-red-900/20 border border-red-500/30 text-red-400 p-4 rounded mb-4">
          Error: {error}
        </div>
      )}

      <div className="space-y-4">
        {results.map((result) => (
          <div key={result.id} className="bg-gray-800 border border-green-500/20 p-4 rounded">
            <h3 className="text-lg font-semibold text-green-300">{result.comm_name}</h3>
            <p className="text-green-400/80">by {result.comm_author}</p>
            <p className="text-sm text-green-400/60">
              {result.comm_lang} • Relevance: {(result.relevance_score * 100).toFixed(1)}%
            </p>
          </div>
        ))}
      </div>
    </div>
  )
}
```

### **Commentary Stats Dashboard**
```typescript
// components/CommentaryDashboard.tsx
import { useCommentaryStats } from '@/hooks/useCommentaryStats'

interface Props {
  commentaryId: string
}

export function CommentaryDashboard({ commentaryId }: Props) {
  const { stats, loading, error } = useCommentaryStats(commentaryId)

  if (loading) return <div className="text-green-400">Loading stats...</div>
  if (error) return <div className="text-red-400">Error: {error}</div>
  if (!stats) return <div className="text-green-400/60">No stats available</div>

  return (
    <div className="bg-gray-900 text-green-400 p-6 rounded-lg border border-green-500/20">
      <h2 className="text-xl font-bold text-green-300 mb-4">Commentary Statistics</h2>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="bg-gray-800 p-4 rounded">
          <div className="text-2xl font-bold text-green-300">{stats.total_texts}</div>
          <div className="text-sm text-green-400/80">Total Texts</div>
        </div>
        <div className="bg-gray-800 p-4 rounded">
          <div className="text-2xl font-bold text-green-300">{stats.canticas_covered}</div>
          <div className="text-sm text-green-400/80">Canticas</div>
        </div>
        <div className="bg-gray-800 p-4 rounded">
          <div className="text-2xl font-bold text-green-300">{stats.cantos_covered}</div>
          <div className="text-sm text-green-400/80">Cantos</div>
        </div>
        <div className="bg-gray-800 p-4 rounded">
          <div className="text-2xl font-bold text-green-300">{stats.lines_covered}</div>
          <div className="text-sm text-green-400/80">Lines</div>
        </div>
      </div>
    </div>
  )
}
```

---

## **4. TheTechMargin Styling Guide**

### **Tailwind Configuration**
```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        'dante-dark': '#0a0f0a',
        'dante-green': {
          50: '#f0fdf4',
          100: '#dcfce7',
          200: '#bbf7d0',
          300: '#86efac',
          400: '#4ade80', // Primary green
          500: '#22c55e',
          600: '#16a34a',
          700: '#15803d',
          800: '#166534',
          900: '#14532d'
        }
      }
    }
  }
}
```

### **Component Base Styles**
```css
/* globals.css */
.dante-container {
  @apply bg-gray-900 text-green-400;
}

.dante-card {
  @apply bg-gray-800 border border-green-500/20 rounded-lg p-6;
}

.dante-button {
  @apply bg-green-600 hover:bg-green-700 disabled:bg-gray-600 text-white px-4 py-2 rounded;
}

.dante-input {
  @apply bg-gray-800 text-green-400 border border-green-500/30 rounded px-4 py-2 placeholder:text-green-400/60;
}
```

---

## **5. Error Handling & Loading States**

### **Error Boundary**
```typescript
// components/ErrorBoundary.tsx
import React from 'react'

export function ErrorBoundary({ children }: { children: React.ReactNode }) {
  return (
    <div className="bg-red-900/20 border border-red-500/30 text-red-400 p-4 rounded">
      <h3 className="font-semibold mb-2">Something went wrong</h3>
      <p className="text-sm">Please try refreshing the page or contact support.</p>
      {children}
    </div>
  )
}
```

### **Loading Spinner**
```typescript
// components/LoadingSpinner.tsx
export function LoadingSpinner() {
  return (
    <div className="flex items-center justify-center p-8">
      <div className="animate-spin rounded-full h-8 w-8 border-2 border-green-400 border-t-transparent"></div>
      <span className="ml-3 text-green-400">Loading...</span>
    </div>
  )
}
```

---

## **6. Performance Optimization**

### **Data Caching Hook**
```typescript
// hooks/useCache.ts
import { useState, useEffect, useRef } from 'react'

export function useCache<T>(key: string, fetcher: () => Promise<T>, ttl: number = 300000) {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)
  const cacheRef = useRef<{ data: T; timestamp: number } | null>(null)

  useEffect(() => {
    const cached = cacheRef.current
    const now = Date.now()
    
    if (cached && (now - cached.timestamp < ttl)) {
      setData(cached.data)
      setLoading(false)
      return
    }

    setLoading(true)
    fetcher()
      .then((result) => {
        cacheRef.current = { data: result, timestamp: now }
        setData(result)
      })
      .finally(() => setLoading(false))
  }, [key, ttl])

  return { data, loading }
}
```

---

## **7. Testing Setup**

### **Hook Testing**
```typescript
// __tests__/hooks/useCommentarySearch.test.ts
import { renderHook, waitFor } from '@testing-library/react'
import { useCommentarySearch } from '@/hooks/useCommentarySearch'

jest.mock('@/lib/supabase', () => ({
  supabase: {
    rpc: jest.fn()
  }
}))

describe('useCommentarySearch', () => {
  it('should search commentaries successfully', async () => {
    const mockData = [{ id: '1', comm_name: 'Test', comm_author: 'Author' }]
    
    ;(supabase.rpc as jest.Mock).mockResolvedValue({ data: mockData, error: null })
    
    const { result } = renderHook(() => useCommentarySearch())
    
    await result.current.searchCommentaries('dante')
    
    await waitFor(() => {
      expect(result.current.results).toEqual(mockData)
      expect(result.current.loading).toBe(false)
    })
  })
})
```

---

## **🎯 Ready for Implementation**

**Backend Status**: ✅ **78 commentaries migrated, all functions operational**

**Frontend Team**: Use these hooks to build the Dante commentary interface with TheTechMargin branding. All backend functionality is tested and ready for integration.
