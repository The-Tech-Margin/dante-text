# Alexandria Dataset React Hooks Guide
## **Historical Commentary Integration for Next.js Frontend**

## 🚀 **Quick Setup**

### **1. Install Dependencies**
```bash
npm install @tanstack/react-query zustand
npm install -D @types/react
```

### **2. TypeScript Interfaces**
Create `types/alexandria.ts`:

```typescript
export type VersionSource = 'original_1991' | 'post_1991' | 'current_2024' | 'alexandria_archive' | 'unknown';
export type EditorialStatus = 'published' | 'draft' | 'revision' | 'archived' | 'fragment';
export type CanticaType = 'inferno' | 'purgatorio' | 'paradiso' | 'general';
export type LanguageType = 'latin' | 'italian' | 'english';
export type TextType = 'commentary' | 'poem' | 'description' | 'proemio' | 'conclusione';

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
    comm_lang: string;
    bibliography: string;
    is_historical: false;
    version_source: 'current_2024';
    created_at: string;
  } | null;
  historical: Array<{
    id: string;
    comm_name: string;
    comm_author: string;
    comm_lang: string;
    bibliography: string;
    is_historical: true;
    version_source: VersionSource;
    created_at: string;
  }>;
  textCounts: Record<string, number>;
}

// New interface for embedded resource queries
export interface EmbeddedCommentaryText {
  id: string;
  doc_id: string;
  commentary_id: string;
  cantica: CanticaType;
  canto_id: number;
  start_line: number;
  end_line: number;
  content: string;
  dde_commentaries: {
    id: string;
    comm_id: string;
    comm_name: string;
    comm_author: string;
    comm_lang: LanguageType;
    comm_pub_year?: string;
  };
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
```

## 🎣 **Core React Hooks**

### **3. Alexandria Query Hooks**
Create `hooks/useAlexandria.ts`:

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type {
  AlexandriaCommentaryVersion,
  AlexandriaHistoricalText,
  CommentaryTimeline,
  PassageVariant,
  CrossVersionSearchResult,
  QueryConfig,
  CanticaType,
  VersionSource
} from '@/types/alexandria';

/**
 * Hook: Get commentary timeline (current + all historical versions)
 */
export const useCommentaryTimeline = (commentaryName: string) => {
  return useQuery({
    queryKey: ['alexandria', 'timeline', commentaryName],
    queryFn: async (): Promise<CommentaryTimeline> => {
      // Get current commentary
      const { data: currentCommentary } = await supabase
        .from('dde_commentaries')
        .select('*')
        .eq('comm_name', commentaryName)
        .single();

      // Get historical versions
      const { data: historicalVersions } = await supabase
        .from('alex_commentary_versions')
        .select(`
          *,
          dde_commentaries!base_commentary_id (*)
        `)
        .eq('dde_commentaries.comm_name', commentaryName);

      // Get text counts for each version
      const textCounts: Record<string, number> = {};

      if (currentCommentary) {
        const { count } = await supabase
          .from('dde_texts')
          .select('*', { count: 'exact', head: true })
          .eq('commentary_id', currentCommentary.id);
        
        textCounts['current_2024'] = count || 0;
      }

      if (historicalVersions) {
        for (const version of historicalVersions) {
          const { count } = await supabase
            .from('alex_texts_historical')
            .select('*', { count: 'exact', head: true })
            .eq('commentary_version_id', version.id);
          
          textCounts[version.version_source] = count || 0;
        }
      }

      return {
        current: currentCommentary ? {
          ...currentCommentary,
          is_historical: false,
          version_source: 'current_2024' as const
        } : null,
        historical: historicalVersions?.map(v => ({
          id: v.id,
          comm_name: v.dde_commentaries?.comm_name || '',
          comm_author: v.dde_commentaries?.comm_author || '',
          comm_lang: v.dde_commentaries?.comm_lang || '',
          bibliography: v.editor_notes || '',
          is_historical: true,
          version_source: v.version_source,
          created_at: v.created_at
        })) || [],
        textCounts
      };
    },
    enabled: !!commentaryName,
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
};

/**
 * Hook: Compare passage across all versions
 */
export const usePassageVariants = (
  cantica: CanticaType,
  canto: number,
  startLine: number,
  endLine: number
) => {
  return useQuery({
    queryKey: ['alexandria', 'variants', cantica, canto, startLine, endLine],
    queryFn: async (): Promise<{
      current: EmbeddedCommentaryText[];
      coverage: any[];
      historical: PassageVariant[];
      variants: { commentary: string; differences: number }[];
    }> => {
      // Get current texts for passage using embedded resource table
      const { data: currentTexts } = await supabase
        .from('dde_texts_with_commentary')
        .select('*')
        .eq('cantica', cantica)
        .eq('canto_id', canto)
        .gte('start_line', startLine)
        .lte('end_line', endLine)
        .limit(20);
      
      // Also get via function for coverage analysis
      const { data: coverageTexts } = await supabase
        .rpc('compare_commentaries_by_passage', {
          input_cantica: cantica,
          input_canto: canto,
          input_start_line: startLine,
          input_end_line: endLine
        });

      // Get historical variants using Alexandria function
      const { data: historicalVariants } = await supabase
        .rpc('alex_find_passage_variants', {
          input_cantica: cantica,
          input_canto: canto,
          input_start_line: startLine,
          input_end_line: endLine
        });

      // Calculate textual differences
      const variants = historicalVariants?.map(variant => ({
        commentary: variant.commentary_name,
        differences: calculateTextDifferences(
          currentTexts?.find(c => c.comm_name === variant.commentary_name)?.content_preview || '',
          variant.content_preview
        )
      })) || [];

      return {
        current: currentTexts || [],
        coverage: coverageTexts || [], // Additional coverage analysis
        historical: historicalVariants || [],
        variants
      };
    },
    enabled: !!(cantica && canto && startLine !== undefined && endLine !== undefined),
    staleTime: 10 * 60 * 1000, // 10 minutes
  });
};

/**
 * Hook: Cross-version search with historical data
 */
export const useCrossVersionSearch = (
  searchTerm: string,
  config: QueryConfig = {}
) => {
  return useQuery({
    queryKey: ['alexandria', 'search', searchTerm, config],
    queryFn: async (): Promise<CrossVersionSearchResult[]> => {
      const { data } = await supabase.rpc('alex_scholarly_search_all_versions', {
        search_term: searchTerm,
        include_historical: config.includeHistorical ?? true,
        version_filter: config.versionFilter || null,
        result_limit: config.limit || 50 // Function now accepts result_limit parameter
      });

      return data || [];
    },
    enabled: !!searchTerm && searchTerm.length > 2,
    staleTime: 2 * 60 * 1000, // 2 minutes
  });
};

/**
 * Hook: Get historical texts for a specific commentary version
 */
export const useHistoricalTexts = (
  commentaryName: string,
  versionSource?: VersionSource,
  config: QueryConfig = {}
) => {
  return useQuery({
    queryKey: ['alexandria', 'historical-texts', commentaryName, versionSource, config],
    queryFn: async (): Promise<AlexandriaHistoricalText[]> => {
      let query = supabase
        .from('alex_texts_historical')
        .select('*')
        .eq('commentary_name', commentaryName);

      if (versionSource) {
        query = query.eq('version_source', versionSource); // Direct field access
      }

      if (config.canticas?.length) {
        query = query.in('cantica', config.canticas);
      }

      if (config.limit) {
        query = query.limit(config.limit);
      }

      query = query.order('canto_id', { ascending: true })
                   .order('start_line', { ascending: true });

      const { data, error } = await query;
      
      if (error) throw error;
      return data || [];
    },
    enabled: !!commentaryName,
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
};

/**
 * Hook: Get commentary network relationships
 */
export const useCommentaryNetwork = (commentaryId: string, maxDepth: number = 2) => {
  return useQuery({
    queryKey: ['alexandria', 'network', commentaryId, maxDepth],
    queryFn: async () => {
      const { data } = await supabase.rpc('alex_get_commentary_network', {
        input_commentary_id: commentaryId,
        max_depth: maxDepth
      });

      return data || [];
    },
    enabled: !!commentaryId,
    staleTime: 10 * 60 * 1000, // 10 minutes
  });
};

/**
 * Hook: Get commentary version history
 */
export const useCommentaryVersions = (commentaryName: string) => {
  return useQuery({
    queryKey: ['alexandria', 'versions', commentaryName],
    queryFn: async (): Promise<AlexandriaCommentaryVersion[]> => {
      const { data } = await supabase.rpc('alex_compare_commentary_versions', {
        input_commentary_name: commentaryName
      });

      return data || [];
    },
    enabled: !!commentaryName,
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
};

// Helper function for text similarity calculation
function calculateTextDifferences(text1: string, text2: string): number {
  if (!text1 || !text2) return 100;
  
  const words1 = text1.toLowerCase().split(/\s+/).filter(w => w.length > 2);
  const words2 = text2.toLowerCase().split(/\s+/).filter(w => w.length > 2);
  
  const set1 = new Set(words1);
  const set2 = new Set(words2);
  
  const intersection = new Set([...set1].filter(x => set2.has(x)));
  const union = new Set([...set1, ...set2]);
  
  return union.size > 0 ? Math.round((1 - intersection.size / union.size) * 100) : 100;
}
```

## 🎯 **Specialized Component Hooks**

### **4. UI Component Integration Hooks**
Create `hooks/useAlexandriaComponents.ts`:

```typescript
import { useState, useMemo } from 'react';
import { useCommentaryTimeline, usePassageVariants, useCrossVersionSearch } from './useAlexandria';
import type { VersionSource, CanticaType, QueryConfig } from '@/types/alexandria';

/**
 * Hook: Timeline comparison component
 */
export const useTimelineComparison = (commentaryName: string) => {
  const [selectedVersions, setSelectedVersions] = useState<VersionSource[]>([]);
  const { data: timeline, isLoading, error } = useCommentaryTimeline(commentaryName);

  const availableVersions = useMemo(() => {
    if (!timeline) return [];
    
    const versions = timeline.historical.map(h => h.version_source);
    if (timeline.current) versions.push('current_2024' as VersionSource);
    
    return versions;
  }, [timeline]);

  const toggleVersion = (version: VersionSource) => {
    setSelectedVersions(prev => 
      prev.includes(version) 
        ? prev.filter(v => v !== version)
        : [...prev, version]
    );
  };

  return {
    timeline,
    availableVersions,
    selectedVersions,
    toggleVersion,
    isLoading,
    error
  };
};

/**
 * Hook: Passage comparison component
 */
export const usePassageComparison = () => {
  const [passage, setPassage] = useState<{
    cantica: CanticaType;
    canto: number;
    startLine: number;
    endLine: number;
  } | null>(null);

  const { data: variants, isLoading, error } = usePassageVariants(
    passage?.cantica || 'inferno',
    passage?.canto || 1,
    passage?.startLine || 1,
    passage?.endLine || 10
  );

  const setPassageSelection = (
    cantica: CanticaType,
    canto: number,
    startLine: number,
    endLine: number
  ) => {
    setPassage({ cantica, canto, startLine, endLine });
  };

  return {
    passage,
    variants,
    setPassageSelection,
    isLoading: isLoading && !!passage,
    error
  };
};

/**
 * Hook: Advanced search with filters
 */
export const useAdvancedSearch = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [filters, setFilters] = useState<QueryConfig>({
    includeHistorical: true,
    versionFilter: undefined,
    languages: undefined,
    canticas: undefined,
    limit: 50
  });

  const { data: results, isLoading, error } = useCrossVersionSearch(searchTerm, filters);

  const updateFilter = <K extends keyof QueryConfig>(key: K, value: QueryConfig[K]) => {
    setFilters(prev => ({ ...prev, [key]: value }));
  };

  const resetFilters = () => {
    setFilters({
      includeHistorical: true,
      versionFilter: undefined,
      languages: undefined,
      canticas: undefined,
      limit: 50
    });
  };

  return {
    searchTerm,
    setSearchTerm,
    filters,
    updateFilter,
    resetFilters,
    results,
    isLoading,
    error
  };
};
```

## 🧩 **React Query Setup**

### **5. Query Client Configuration**
Update `lib/queryClient.ts`:

```typescript
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 2 * 60 * 1000, // 2 minutes
      cacheTime: 10 * 60 * 1000, // 10 minutes
      retry: 2,
      refetchOnWindowFocus: false,
    },
    mutations: {
      retry: 1,
    },
  },
});

// Alexandria-specific query keys for cache management
export const alexandriaKeys = {
  all: ['alexandria'] as const,
  timeline: (commentaryName: string) => ['alexandria', 'timeline', commentaryName] as const,
  variants: (cantica: string, canto: number, startLine: number, endLine: number) => 
    ['alexandria', 'variants', cantica, canto, startLine, endLine] as const,
  search: (term: string, config: any) => ['alexandria', 'search', term, config] as const,
  historicalTexts: (commentaryName: string, version?: string) => 
    ['alexandria', 'historical-texts', commentaryName, version] as const,
  network: (commentaryId: string, depth: number) => 
    ['alexandria', 'network', commentaryId, depth] as const,
  versions: (commentaryName: string) => ['alexandria', 'versions', commentaryName] as const,
};
```

## 🎨 **Component Examples**

### **6. Timeline Comparison Component**
Create `components/AlexandriaTimeline.tsx`:

```tsx
'use client';

import { Suspense } from 'react';
import { useTimelineComparison } from '@/hooks/useAlexandriaComponents';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Checkbox } from '@/components/ui/checkbox';

interface AlexandriaTimelineProps {
  commentaryName: string;
}

function TimelineContent({ commentaryName }: AlexandriaTimelineProps) {
  const {
    timeline,
    availableVersions,
    selectedVersions,
    toggleVersion,
    isLoading,
    error
  } = useTimelineComparison(commentaryName);

  if (isLoading) return <div className="animate-pulse">Loading timeline...</div>;
  if (error) return <div className="text-red-500">Error loading timeline</div>;
  if (!timeline) return <div>No timeline data available</div>;

  return (
    <Card className="bg-gray-900 border-gray-800">
      <CardHeader>
        <CardTitle className="text-ttm-cyan">
          Commentary Timeline: {commentaryName}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {/* Current Version */}
          {timeline.current && (
            <div className="flex items-center space-x-3 p-3 bg-gray-800 rounded-lg">
              <Checkbox 
                checked={selectedVersions.includes('current_2024')}
                onCheckedChange={() => toggleVersion('current_2024')}
              />
              <div className="flex-1">
                <Badge className="bg-ttm-cyan text-black mb-2">Current</Badge>
                <p className="text-gray-300">{timeline.current.comm_author}</p>
                <p className="text-sm text-gray-500">
                  {timeline.textCounts['current_2024']} text segments
                </p>
              </div>
            </div>
          )}

          {/* Historical Versions */}
          {timeline.historical.map((version) => (
            <div key={version.id} className="flex items-center space-x-3 p-3 bg-gray-800 rounded-lg">
              <Checkbox 
                checked={selectedVersions.includes(version.version_source)}
                onCheckedChange={() => toggleVersion(version.version_source)}
              />
              <div className="flex-1">
                <Badge variant="outline" className="border-gray-600 text-gray-300 mb-2">
                  {version.version_source.replace('_', ' ')}
                </Badge>
                <p className="text-gray-300">{version.bibliography}</p>
                <p className="text-sm text-gray-500">
                  {timeline.textCounts[version.version_source] || 0} text segments
                </p>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
}

export default function AlexandriaTimeline({ commentaryName }: AlexandriaTimelineProps) {
  return (
    <Suspense fallback={<div className="animate-pulse h-64 bg-gray-900 rounded-lg" />}>
      <TimelineContent commentaryName={commentaryName} />
    </Suspense>
  );
}
```

### **7. Cross-Version Search Component**
Create `components/AlexandriaSearch.tsx`:

```tsx
'use client';

import { Suspense } from 'react';
import { useAdvancedSearch } from '@/hooks/useAlexandriaComponents';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent } from '@/components/ui/card';
import { Search, Filter } from 'lucide-react';

function SearchContent() {
  const {
    searchTerm,
    setSearchTerm,
    filters,
    updateFilter,
    results,
    isLoading,
    error
  } = useAdvancedSearch();

  return (
    <div className="space-y-4">
      {/* Search Input */}
      <div className="relative">
        <Search className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
        <Input
          placeholder="Search across all commentary versions..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="pl-10 bg-gray-900 border-gray-700 text-white placeholder-gray-400"
        />
      </div>

      {/* Filters */}
      <div className="flex items-center gap-2 flex-wrap">
        <Filter className="h-4 w-4 text-gray-400" />
        <Badge
          variant={filters.includeHistorical ? "default" : "outline"}
          className={filters.includeHistorical ? "bg-ttm-cyan text-black" : ""}
          onClick={() => updateFilter('includeHistorical', !filters.includeHistorical)}
        >
          Include Historical
        </Badge>
        {/* Add more filter badges as needed */}
      </div>

      {/* Results */}
      {isLoading && <div className="animate-pulse">Searching...</div>}
      {error && <div className="text-red-500">Search error</div>}
      
      {results && (
        <div className="space-y-2">
          <p className="text-sm text-gray-400">{results.length} results found</p>
          {results.map((result, index) => (
            <Card key={index} className="bg-gray-900 border-gray-800">
              <CardContent className="p-4">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <Badge variant="outline" className="border-gray-600 text-gray-300">
                        {result.commentary_name}
                      </Badge>
                      <Badge 
                        className={result.is_historical ? "bg-amber-600" : "bg-ttm-cyan text-black"}
                      >
                        {result.version_source.replace('_', ' ')}
                      </Badge>
                      <span className="text-sm text-gray-500">
                        {result.cantica} {result.canto_id}
                      </span>
                    </div>
                    <p className="text-gray-300 text-sm line-clamp-3">
                      {result.content_match}
                    </p>
                  </div>
                  <div className="ml-4 text-right">
                    <div className="text-xs text-gray-500">
                      Relevance: {Math.round(result.relevance_score * 100)}%
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}

export default function AlexandriaSearch() {
  return (
    <Suspense fallback={<div className="animate-pulse h-32 bg-gray-900 rounded-lg" />}>
      <SearchContent />
    </Suspense>
  );
}
```

## 🔧 **Provider Setup**

### **8. App Configuration**
Update `app/layout.tsx`:

```tsx
'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { queryClient } from '@/lib/queryClient';

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <QueryClientProvider client={queryClient}>
          {children}
          <ReactQueryDevtools initialIsOpen={false} />
        </QueryClientProvider>
      </body>
    </html>
  );
}
```

## 📚 **Usage Examples**

### **9. Page Integration Example**
```tsx
// app/commentary/[name]/page.tsx
'use client';

import { Suspense } from 'react';
import AlexandriaTimeline from '@/components/AlexandriaTimeline';
import AlexandriaSearch from '@/components/AlexandriaSearch';
import { useCommentaryTimeline, usePassageVariants } from '@/hooks/useAlexandria';

export default function CommentaryPage({ params }: { params: { name: string } }) {
  return (
    <div className="container mx-auto py-8 space-y-8">
      <Suspense fallback={<div>Loading...</div>}>
        <AlexandriaTimeline commentaryName={params.name} />
      </Suspense>
      
      <Suspense fallback={<div>Loading...</div>}>
        <AlexandriaSearch />
      </Suspense>
      
      {/* Example of passage variant analysis */}
      <Suspense fallback={<div>Loading...</div>}>
        <PassageVariantAnalysis cantica="inferno" canto={1} startLine={1} endLine={10} />
      </Suspense>
    </div>
  );
}

// Helper component using embedded resource table
function PassageVariantAnalysis({ cantica, canto, startLine, endLine }) {
  const { data: variants, isLoading } = usePassageVariants(cantica, canto, startLine, endLine);
  
  if (isLoading) return <div>Loading variants...</div>;
  
  return (
    <div className="bg-gray-900 p-4 rounded-lg">
      <h3 className="text-ttm-cyan mb-4">Passage Variants: {cantica} {canto}:{startLine}-{endLine}</h3>
      <p>Found {variants?.current?.length || 0} current versions</p>
      <p>Found {variants?.historical?.length || 0} historical variants</p>
    </div>
  );
}
```

## 🚀 **Performance Optimizations**

### **10. Advanced Patterns**
```tsx
// Prefetch patterns for better UX
export const prefetchCommentaryData = (queryClient: QueryClient, commentaryName: string) => {
  queryClient.prefetchQuery({
    queryKey: ['alexandria', 'timeline', commentaryName],
    queryFn: () => fetchCommentaryTimeline(commentaryName),
    staleTime: 5 * 60 * 1000,
  });
};

// Optimistic updates for better perceived performance
export const useOptimisticCommentaryUpdate = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: updateCommentaryVersion,
    onMutate: async (newData) => {
      await queryClient.cancelQueries({ queryKey: ['alexandria'] });
      const previousData = queryClient.getQueryData(['alexandria', 'timeline', newData.commentaryName]);
      queryClient.setQueryData(['alexandria', 'timeline', newData.commentaryName], newData);
      return { previousData };
    },
    onError: (err, newData, context) => {
      queryClient.setQueryData(['alexandria', 'timeline', newData.commentaryName], context?.previousData);
    },
    onSettled: (data, error, variables) => {
      queryClient.invalidateQueries({ queryKey: ['alexandria', 'timeline', variables.commentaryName] });
    },
  });
};
```

---

## 📋 **Quick Checklist**

- [ ] Install dependencies (`@tanstack/react-query`, `zustand`)
- [ ] Create TypeScript interfaces (`types/alexandria.ts`)
- [ ] Implement core hooks (`hooks/useAlexandria.ts`)
- [ ] Create component hooks (`hooks/useAlexandriaComponents.ts`)
- [ ] Setup Query Client (`lib/queryClient.ts`)
- [ ] Build UI components (`components/Alexandria*.tsx`)
- [ ] Configure app providers (`app/layout.tsx`)
- [ ] Test with existing commentary data
- [ ] Deploy and verify with production data

The hooks are designed to work seamlessly with your existing Next.js 15.1+ setup and TTM design system while providing comprehensive access to the Alexandria historical dataset.
