# Frontend Specifications: Dante Commentary Platform
## **TheTechMargin Dark Mode Design System**

## 🏗️ **Architecture Overview**

**Tech Stack (TTM Standards):**
- **Framework**: Next.js 15.1+ with TypeScript
- **Database**: Supabase (PostgreSQL)
- **Styling**: Tailwind CSS with TTM custom theme
- **Fonts**: Poppins (primary) + Pacifico (brand accents)
- **State Management**: Zustand or React Query
- **Theme**: Dark mode default with TTM brand colors
- **Performance**: React Suspense + virtualization

## 🎨 **TTM Brand Design System**

### **Color Palette**

#### **Primary Brand Colors**
```css
:root {
  /* TTM Core Colors */
  --ttm-cyan: #09fff0;      /* Primary accent, highlights, buttons */
  --ttm-magenta: #ff2d8a;   /* Secondary accent, CTAs, hover states */
  --ttm-black: #000000;     /* Main backgrounds, primary text */
  
  /* Supporting Dark Theme */
  --ttm-deep-black: #0D0D0D;   /* Card backgrounds, elevated surfaces */
  --ttm-dark-gray: #333333;    /* Secondary text, headers */
  --ttm-medium-gray: #a3a3a3;  /* Metadata, borders */
  --ttm-light-gray: #f5f5f5;   /* Minimal light accents */
  
  /* Interactive States */
  --ttm-cyan-hover: rgba(9, 255, 240, 0.9);
  --ttm-cyan-active: rgba(9, 255, 240, 0.2);
  --ttm-magenta-hover: rgba(255, 45, 138, 0.9);
  
  /* Gradients */
  --ttm-primary-gradient: linear-gradient(135deg, #09fff0 0%, #ff2d8a 100%);
  --ttm-cyan-gradient: linear-gradient(135deg, #09fff0 0%, #0099cc 100%);
}
```

### **Typography System**

#### **Font Stack**
```css
/* Primary Font - Poppins */
.font-primary {
  font-family: 'Poppins', ui-sans-serif, system-ui, sans-serif;
}

/* Brand Font - Pacifico */
.font-brand {
  font-family: 'Pacifico', cursive;
}

/* Display Text - Brand Headers */
.text-display {
  font-family: 'Pacifico', cursive;
  font-size: 3.75rem; /* 60px */
  color: var(--ttm-cyan);
  text-shadow: 0 0 20px rgba(9, 255, 240, 0.4);
}

/* Page Titles */
.text-h1 {
  font-family: 'Poppins', sans-serif;
  font-size: 3rem; /* 48px */
  font-weight: 700;
  color: #ffffff;
}

/* Section Headers */
.text-h2 {
  font-family: 'Poppins', sans-serif;
  font-size: 2.25rem; /* 36px */
  font-weight: 600;
  color: #ffffff;
}

/* Body Text */
.text-body {
  font-family: 'Poppins', sans-serif;
  font-size: 1rem; /* 16px */
  font-weight: 400;
  color: var(--ttm-medium-gray);
  line-height: 1.6;
}

/* Metadata */
.text-meta {
  font-family: 'Poppins', sans-serif;
  font-size: 0.875rem; /* 14px */
  color: var(--ttm-dark-gray);
}
```

## 📋 **Core Components & API Endpoints**

### 1. **Search & Discovery Interface (TTM Style)**

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

**TTM Search Input Styling:**
```css
.ttm-search-input {
  background: var(--ttm-dark-gray);
  border: 2px solid rgba(9, 255, 240, 0.2);
  border-radius: 12px;
  color: #ffffff;
  font-family: 'Poppins', sans-serif;
  padding: 12px 16px;
  transition: all 0.3s ease;
}

.ttm-search-input:focus {
  border-color: var(--ttm-cyan);
  box-shadow: 0 0 0 3px rgba(9, 255, 240, 0.2);
  outline: none;
}

.ttm-search-input::placeholder {
  color: var(--ttm-medium-gray);
}
```

**API Integration:**
- `POST /api/search/commentaries` → `search_commentaries_ranked()`
- `POST /api/search/texts` → `search_texts_with_context()`
- `POST /api/search/highlights` → `search_with_highlights()`

#### **TTM SearchResults Component**
```css
.ttm-search-results {
  background: var(--ttm-black);
  padding: 20px;
}

.ttm-result-card {
  background: rgba(0, 0, 0, 0.4);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  backdrop-filter: blur(10px);
  margin-bottom: 16px;
  padding: 20px;
  transition: all 0.3s ease;
}

.ttm-result-card:hover {
  border-color: rgba(9, 255, 240, 0.4);
  transform: translateY(-4px);
  box-shadow: 0 20px 40px rgba(9, 255, 240, 0.1);
}

.ttm-highlight {
  background: linear-gradient(135deg, 
    rgba(9, 255, 240, 0.2) 0%, 
    rgba(255, 45, 138, 0.2) 100%);
  border-radius: 4px;
  padding: 2px 4px;
}
```

### 2. **Navigation & Browsing (TTM Style)**

#### **TTM NavigationTree Component**
```typescript
interface NavigationNode {
  cantica: 'inferno' | 'purgatorio' | 'paradiso';
  canto_id: number;
  text_count: number;
  line_range: string;
  has_texts: boolean;
}
```

**TTM Navigation Styling:**
```css
.ttm-nav-tree {
  background: var(--ttm-deep-black);
  border-right: 2px solid var(--ttm-cyan);
  padding: 20px;
}

.ttm-nav-item {
  color: var(--ttm-medium-gray);
  padding: 8px 12px;
  border-radius: 8px;
  transition: all 0.3s ease;
  font-family: 'Poppins', sans-serif;
}

.ttm-nav-item:hover {
  background: rgba(9, 255, 240, 0.1);
  color: var(--ttm-cyan);
}

.ttm-nav-item.active {
  background: var(--ttm-primary-gradient);
  color: var(--ttm-black);
  font-weight: 600;
}

.ttm-nav-badge {
  background: var(--ttm-magenta);
  color: #ffffff;
  border-radius: 20px;
  padding: 2px 8px;
  font-size: 0.75rem;
  font-weight: 600;
}
```

**API Integration:**
- `GET /api/navigation/tree?commentary_id={id}` → `get_navigation_tree()`

### 3. **Commentary Analysis Dashboard (TTM Style)**

#### **TTM CommentaryStats Component**
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

**TTM Stats Card Styling:**
```css
.ttm-stats-card {
  background: var(--ttm-deep-black);
  border: 2px solid;
  border-image: var(--ttm-primary-gradient) 1;
  border-radius: 12px;
  padding: 24px;
  position: relative;
  overflow: hidden;
}

.ttm-stats-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: var(--ttm-primary-gradient);
}

.ttm-stat-number {
  font-size: 2.5rem;
  font-weight: 700;
  color: var(--ttm-cyan);
  font-family: 'Poppins', sans-serif;
}

.ttm-stat-label {
  color: var(--ttm-medium-gray);
  font-size: 0.875rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
```

**API Integration:**
- `GET /api/commentary/{id}/stats` → `get_commentary_stats()`

### 4. **Comparative Analysis Interface (TTM Style)**

#### **TTM PassageComparison Component**
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

**TTM Comparison Panel Styling:**
```css
.ttm-comparison-panel {
  background: var(--ttm-deep-black);
  border-left: 4px solid var(--ttm-cyan);
  border-radius: 0 8px 8px 0;
  padding: 20px;
  margin-bottom: 16px;
}

.ttm-comparison-panel:nth-child(even) {
  border-left-color: var(--ttm-magenta);
}

.ttm-coverage-score {
  display: inline-block;
  background: var(--ttm-cyan-gradient);
  color: var(--ttm-black);
  padding: 4px 12px;
  border-radius: 20px;
  font-weight: 600;
  font-size: 0.875rem;
}
```

**API Integration:**
- `POST /api/analysis/compare-passage` → `compare_commentaries_by_passage()`

## 🎯 **TTM UI Component Library**

### **Buttons**

```css
/* Primary Button - TTM Cyan */
.ttm-btn-primary {
  background: var(--ttm-cyan-gradient);
  color: var(--ttm-black);
  font-family: 'Poppins', sans-serif;
  font-weight: 600;
  padding: 12px 24px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
}

.ttm-btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(9, 255, 240, 0.4);
}

/* Secondary Button - TTM Magenta */
.ttm-btn-secondary {
  background: linear-gradient(135deg, var(--ttm-magenta) 0%, #cc0066 100%);
  color: #ffffff;
  font-family: 'Poppins', sans-serif;
  font-weight: 500;
  padding: 12px 24px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
}

/* Tertiary Button - TTM Cyan Outline */
.ttm-btn-tertiary {
  background: transparent;
  color: var(--ttm-cyan);
  border: 2px solid var(--ttm-cyan);
  font-family: 'Poppins', sans-serif;
  font-weight: 500;
  padding: 10px 22px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.ttm-btn-tertiary:hover {
  background: var(--ttm-cyan-active);
}
```

### **Cards & Panels**

```css
.ttm-card-standard {
  background: rgba(0, 0, 0, 0.4);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  backdrop-filter: blur(10px);
  padding: 20px;
  transition: all 0.3s ease;
}

.ttm-card-featured {
  background: var(--ttm-deep-black);
  border: 2px solid;
  border-image: var(--ttm-primary-gradient) 1;
  border-radius: 12px;
  padding: 24px;
  position: relative;
}

.ttm-card-glow {
  box-shadow: 0 0 30px rgba(9, 255, 240, 0.3);
}
```

### **Form Elements**

```css
.ttm-input {
  background: var(--ttm-dark-gray);
  border: 2px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  color: #ffffff;
  font-family: 'Poppins', sans-serif;
  padding: 12px 16px;
  transition: all 0.3s ease;
}

.ttm-input:focus {
  border-color: var(--ttm-cyan);
  box-shadow: 0 0 0 3px rgba(9, 255, 240, 0.2);
  outline: none;
}

.ttm-select {
  background: var(--ttm-dark-gray);
  border: 2px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  color: #ffffff;
  font-family: 'Poppins', sans-serif;
}
```

## 🚀 **TTM Animations & Effects**

### **Brand Animations**

```css
/* Shimmer Effect */
@keyframes ttm-shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}

.ttm-shimmer {
  background: linear-gradient(90deg, 
    transparent, 
    rgba(9, 255, 240, 0.4), 
    transparent);
  background-size: 200% 100%;
  animation: ttm-shimmer 2s infinite;
}

/* Float Animation */
@keyframes ttm-float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
}

.ttm-float {
  animation: ttm-float 3s ease-in-out infinite;
}

/* Glow Effects */
.ttm-glow-cyan {
  box-shadow: 0 0 30px rgba(9, 255, 240, 0.3);
}

.ttm-glow-magenta {
  box-shadow: 0 0 20px rgba(255, 45, 138, 0.4);
}

/* Pulse Effect */
@keyframes ttm-pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

.ttm-pulse {
  animation: ttm-pulse 2s infinite;
}
```

## 📱 **Responsive Design (TTM Standards)**

### **Breakpoints**
```css
/* TTM Responsive Breakpoints */
.ttm-mobile { /* 375px - 768px */ }
.ttm-tablet { /* 768px - 1024px */ }
.ttm-desktop { /* 1024px - 1440px */ }
.ttm-large { /* 1440px+ */ }
```

### **Mobile-First TTM Layout**
```css
.ttm-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

@media (max-width: 768px) {
  .ttm-container {
    padding: 0 16px;
  }
  
  .text-h1 {
    font-size: 2rem;
  }
  
  .ttm-nav-tree {
    position: fixed;
    left: -100%;
    transition: left 0.3s ease;
  }
  
  .ttm-nav-tree.open {
    left: 0;
  }
}
```

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
