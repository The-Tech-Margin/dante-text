# Frontend Specifications: Dante Commentary Platform

## 🏗️ **Architecture Overview**

**Tech Stack Recommendation:**
- **Framework**: Next.js 15.1+ with TypeScript
- **Database**: Supabase (PostgreSQL)
- **Styling**: Tailwind CSS + shadcn/ui components
- **State Management**: Zustand or React Query
- **Search**: Real-time with debounced queries
- **Performance**: React Suspense + virtualization

## 📋 **Core Components & API Endpoints**

### 1. **Search & Discovery Interface**

#### **GlobalSearchBar Component**
```typescript
interface SearchBarProps {
  onSearch: (query: string, filters?: SearchFilters) => void;
  placeholder?: string;
  autoFocus?: boolean;
}

interface SearchFilters {
  language?: 'latin' | 'italian' | 'english';
  cantica?: 'inferno' | 'purgatorio' | 'paradiso';
  commentaryIds?: string[];
}
```

**API Integration:**
- `POST /api/search/commentaries` → `search_commentaries_ranked()`
- `POST /api/search/texts` → `search_texts_with_context()`
- `POST /api/search/highlights` → `search_with_highlights()`

#### **SearchResults Component**
- **Infinite scrolling** with virtualized results
- **Ranked relevance** display with score indicators
- **Text highlighting** with `<mark>` tags
- **Filter sidebar** with real-time counts

### 2. **Navigation & Browsing**

#### **NavigationTree Component**
```typescript
interface NavigationNode {
  cantica: 'inferno' | 'purgatorio' | 'paradiso';
  canto_id: number;
  text_count: number;
  line_range: string;
  has_texts: boolean;
}
```

**Features:**
- **Collapsible tree structure** (Cantica → Canto → Line ranges)
- **Badge indicators** showing text counts per section
- **Progress visualization** showing commentary coverage
- **Quick jump navigation** with search-within-tree

**API Integration:**
- `GET /api/navigation/tree?commentary_id={id}` → `get_navigation_tree()`

### 3. **Commentary Analysis Dashboard**

#### **CommentaryStats Component**
```typescript
interface CommentaryStats {
  total_texts: number;
  canticas_covered: number;
  cantos_covered: number;
  lines_covered: number;
  languages_used: string[];
  text_types_used: string[];
  avg_text_length: number;
  last_updated: string;
}
```

**Visualizations:**
- **Coverage heatmap** showing cantica/canto completion
- **Language distribution** pie chart
- **Text length histogram** for content analysis
- **Timeline view** of last updates

**API Integration:**
- `GET /api/commentary/{id}/stats` → `get_commentary_stats()`

### 4. **Comparative Analysis Interface**

#### **PassageComparison Component**
```typescript
interface PassageFilter {
  cantica: 'inferno' | 'purgatorio' | 'paradiso';
  canto: number;
  startLine: number;
  endLine: number;
}

interface CommentaryComparison {
  commentary_id: string;
  commentary_name: string;
  author: string;
  language: string;
  text_excerpt: string;
  coverage_score: number;
}
```

**Features:**
- **Side-by-side commentary** comparison view
- **Passage selector** with line-by-line navigation
- **Coverage scoring** with visual indicators
- **Export functionality** for research citations

**API Integration:**
- `POST /api/analysis/compare-passage` → `compare_commentaries_by_passage()`

## 🎨 **UI/UX Specifications**

### **Design System**

#### **Color Palette**
- **Primary**: Scholarly blue (`#1e40af`) for navigation
- **Secondary**: Renaissance gold (`#f59e0b`) for highlights  
- **Text**: High contrast (`#111827` on `#f9fafb`)
- **Accent**: Dante red (`#dc2626`) for important passages

#### **Typography**
- **Headers**: Inter/System fonts for modern readability
- **Body Text**: Georgia/serif fonts for scholarly content
- **Code/IDs**: JetBrains Mono for doc IDs and metadata

#### **Layout Patterns**
- **Responsive grid**: 12-column system with breakpoints
- **Sidebar navigation**: Collapsible tree on desktop
- **Mobile-first**: Hamburger menu with overlay navigation
- **Accessibility**: WCAG 2.1 AA compliance throughout

### **Interactive Components**

#### **Advanced Search Interface**
```typescript
// Search with real-time suggestions
<SearchInterface>
  <AutoComplete source="/api/suggestions" />
  <FilterPanel>
    <LanguageFilter options={['latin', 'italian', 'english']} />
    <CanticaFilter options={['inferno', 'purgatorio', 'paradiso']} />
    <DateRangeFilter />
  </FilterPanel>
  <ResultsView>
    <InfiniteScroll />
    <HighlightedText />
    <RelevanceScoring />
  </ResultsView>
</SearchInterface>
```

#### **Text Reader Interface**
- **Split-pane view**: Original text + commentary
- **Annotation system**: Click-to-annotate with user notes
- **Cross-references**: Linked citations between commentaries
- **Reading progress**: Bookmark and resume functionality

## 🚀 **Performance Specifications**

### **Core Web Vitals Targets**
- **LCP**: < 2.5s for first content paint
- **FID**: < 100ms for search interactions
- **CLS**: < 0.1 for layout stability

### **Optimization Strategies**

#### **Database Layer**
- **Prepared statements** for all search functions
- **Connection pooling** with Supabase
- **Query result caching** (Redis/Memory)
- **Full-text search indexes** already implemented

#### **Frontend Layer**
```typescript
// React Query for caching and background updates
const useSearchResults = (query: string, filters: SearchFilters) => {
  return useQuery({
    queryKey: ['search', query, filters],
    queryFn: () => searchCommentaries(query, filters),
    staleTime: 5 * 60 * 1000, // 5 minutes
    cacheTime: 10 * 60 * 1000, // 10 minutes
  });
};

// Virtualization for large result sets
<FixedSizeList
  height={600}
  itemCount={searchResults.length}
  itemSize={120}
  renderItem={({ index, style }) => (
    <SearchResultItem result={searchResults[index]} style={style} />
  )}
/>
```

#### **Loading States**
- **Skeleton screens** for search results
- **Suspense boundaries** for code splitting
- **Progressive loading** for large text content
- **Offline capability** with service workers

## 🔌 **API Route Specifications**

### **Search Endpoints**
```typescript
// GET /api/search/commentaries
interface CommentarySearchRequest {
  search_term: string;
  lang_filter?: 'latin' | 'italian' | 'english';
  limit?: number;
}

// GET /api/search/texts
interface TextSearchRequest {
  search_term: string;
  commentary_ids?: string[];
  cantica_filter?: 'inferno' | 'purgatorio' | 'paradiso';
  limit?: number;
}

// GET /api/search/highlights
interface HighlightSearchRequest {
  search_term: string;
  commentary_filter?: string;
  limit?: number;
}
```

### **Analysis Endpoints**
```typescript
// GET /api/commentary/:id/stats
interface StatsResponse {
  total_texts: number;
  coverage_metrics: CoverageMetrics;
  language_distribution: LanguageStats[];
  last_updated: string;
}

// POST /api/analysis/compare-passage  
interface PassageComparisonRequest {
  cantica: 'inferno' | 'purgatorio' | 'paradiso';
  canto: number;
  start_line: number;
  end_line: number;
}
```

### **Navigation Endpoints**
```typescript
// GET /api/navigation/tree
interface NavigationTreeRequest {
  commentary_id?: string;
}

interface NavigationTreeResponse {
  cantica: string;
  canto_id: number;
  text_count: number;
  line_range: string;
  has_texts: boolean;
}[]
```

## 📱 **Mobile Responsive Design**

### **Breakpoints**
- **Mobile**: 320px - 768px
- **Tablet**: 768px - 1024px  
- **Desktop**: 1024px+

### **Mobile-Specific Features**
- **Swipe navigation** between cantos
- **Pull-to-refresh** for content updates
- **Offline reading** with cached commentaries
- **Voice search** integration
- **Text-to-speech** for accessibility

## 🔐 **Authentication & Permissions**

### **User Roles**
- **Public**: Search and read access
- **Scholar**: Annotation and citation tools
- **Editor**: Content management capabilities
- **Admin**: Full database access

### **Supabase Integration**
```typescript
// Row Level Security policies already configured
const { data: commentaries } = await supabase
  .from('dde_commentaries')
  .select('*')
  .eq('visibility', 'public');

// User-specific annotations
const { data: annotations } = await supabase
  .from('user_annotations')
  .select('*')
  .eq('user_id', user.id);
```

## 📊 **Analytics & Monitoring**

### **Key Metrics**
- **Search query patterns** and popular terms
- **Commentary usage statistics** by author/language
- **User engagement** time and navigation paths
- **Performance monitoring** for database queries

### **Implementation**
- **Vercel Analytics** for web vitals
- **Supabase Analytics** for database performance
- **Custom events** for scholarly research patterns
- **Error boundary reporting** with detailed context

## 🎯 **Future Enhancements**

### **Advanced Features**
- **AI-powered commentary** suggestions
- **Collaborative annotation** system
- **Citation management** integration
- **Multi-language translation** overlay
- **Academic export** (BibTeX, Chicago, MLA)
- **Graph visualization** of commentary relationships

This specification provides a complete roadmap for building a modern, performant, and scholarly-grade Dante commentary platform leveraging the optimized Supabase backend functions.
