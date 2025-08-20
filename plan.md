# Dante Database Modernization Plan

_Migrating the Dartmouth Dante Project to Supabase_

## 🎯 **Project Overview**

Modernizing the scholarly Dartmouth Dante Project database from Oracle to Supabase while preserving the 20+ years of commentary data integrity and enhancing performance for modern web applications.

### **Legacy System (Dartmouth)**

- **Database**: Oracle with `ddp_comm_tab` and `ddp_text_tab`
- **Files**: ~80 commentaries in `.e` format across `inf/purg/para` directories
- **Access**: SQL\*Net with limited web interface
- **Doc ID**: 12-character format `cccccannlllt` (comm+cantica+canto+line+tie)

### **Target System (Supabase)**

- **Database**: PostgreSQL with `dde_commentaries` and `dde_texts`
- **Performance**: Optimized functions for sub-second search
- **API**: RESTful endpoints with Next.js integration
- **Frontend**: Modern responsive interface with real-time search

---

## ✅ **Completed Milestones**

### **1. Database Architecture & Schema** _(100% Complete)_

- ✅ Created `dde_commentaries` and `dde_texts` tables with proper constraints
- ✅ Implemented enums for `cantica_type`, `language_type`, `text_type`
- ✅ Added GIN indexes for full-text search performance
- ✅ Preserved original `comm_id` and `doc_id` formats for compatibility

### **2. Performance-Optimized SQL Functions** _(100% Complete)_

- ✅ `search_commentaries_ranked()` - Fast commentary search with relevance scoring
- ✅ `search_texts_with_context()` - Text search with surrounding context
- ✅ `search_with_highlights()` - Search with highlighted matching terms
- ✅ `get_commentary_stats()` - Analytics for commentary coverage and metrics
- ✅ `compare_commentaries_by_passage()` - Side-by-side passage comparison
- ✅ `get_navigation_tree()` - Hierarchical navigation by cantica/canto

### **3. Next.js API Routes** _(100% Complete)_

- ✅ `/api/search/commentaries` - Commentary search endpoint
- ✅ `/api/search/texts` - Text search with filtering
- ✅ `/api/search/highlights` - Highlighted search results
- ✅ `/api/commentary/[id]/stats` - Commentary analytics
- ✅ `/api/analysis/compare-passage` - Passage comparison tool
- ✅ `/api/navigation/tree` - Navigation tree API

### **4. Migration Infrastructure** _(95% Complete)_

- ✅ Commentary metadata parser for `desc.e` files
- ✅ Text segment parser for `.e` canto files
- ✅ Batch insertion system for performance
- ✅ Unique `comm_id` generation with collision handling
- ⚠️ **Current Issue**: `doc_id` uniqueness conflicts during migration

### **5. Documentation & Specifications** _(100% Complete)_

- ✅ Comprehensive frontend specifications (FRONTEND_SPECIFICATIONS.md)
- ✅ Migration guide with troubleshooting (MIGRATION_GUIDE.md)
- ✅ API documentation and TypeScript interfaces
- ✅ Performance optimization strategies

---

## 🔥 **Current Priority: Fix Data Migration**

### **Issue**: Duplicate `doc_id` Constraint Violations

**Status**: Blocking migration completion

**Root Cause**: Multiple commentaries generating identical `doc_id` values for same cantica/canto/line combinations.

**Solution Strategy**:

```javascript
// Current: Fixed tie-breaker causes collisions
doc_id = commId + canticaId + canto + line + "0";

// Fixed: Dynamic tie-breaker with uniqueness tracking
doc_id = commId + canticaId + canto + line + incrementalTieBreaker;
```

**Next Steps**:

1. ⏳ **Fix `generateDocId()` in `lib/parsers.js`** - Implement global uniqueness tracking
2. ⏳ **Clear database and re-run migration** - Test with fixed ID generation
3. ⏳ **Validate 74+ commentaries migrated successfully** - Verify data integrity

---

## 🚀 **Next Phase: Frontend Development**

### **High Priority Features**

1. **Global Search Interface** _(Not Started)_

   - Real-time search with debounced queries
   - Advanced filtering by language, cantica, commentary
   - Infinite scroll with virtualized results
   - Search result highlighting

2. **Navigation & Browsing** _(Not Started)_

   - Collapsible tree structure (Cantica → Canto → Line ranges)
   - Progress indicators showing commentary coverage
   - Quick jump navigation with search-within-tree

3. **Commentary Reading Interface** _(Not Started)_
   - Split-pane view: original text + commentary
   - Cross-references between commentaries
   - Bookmark and reading progress tracking

### **Medium Priority Features**

1. **Comparative Analysis Dashboard** _(Not Started)_

   - Side-by-side commentary comparison
   - Coverage heatmap visualization
   - Language distribution analytics
   - Timeline view of commentary updates

2. **Mobile-Responsive Design** _(Not Started)_
   - Swipe navigation between cantos
   - Pull-to-refresh content updates
   - Offline reading with cached commentaries
   - Voice search integration

### **Advanced Features** _(Future)_

- AI-powered commentary suggestions
- Collaborative annotation system
- Citation management (BibTeX, Chicago, MLA)
- Multi-language translation overlay
- Graph visualization of commentary relationships

---

## 📋 **Implementation Roadmap**

### **Phase 1: Complete Migration** _(Current - Week 1)_

- [ ] Fix `doc_id` uniqueness issue in parsers
- [ ] Complete data migration of all 74+ commentaries
- [ ] Validate data integrity and API functionality
- [ ] Performance test with full dataset

### **Phase 2: Core Frontend** _(Weeks 2-4)_

- [ ] Set up Next.js 15.1+ project with TypeScript
- [ ] Implement global search with real-time results
- [ ] Build navigation tree component
- [ ] Create commentary reading interface
- [ ] Add responsive design for mobile/tablet

### **Phase 3: Advanced Features** _(Weeks 5-8)_

- [ ] Comparative analysis dashboard
- [ ] User authentication and preferences
- [ ] Annotation and bookmarking system
- [ ] Advanced search filters and analytics
- [ ] Performance optimization and caching

### **Phase 4: Scholar Tools** _(Weeks 9-12)_

- [ ] Citation management integration
- [ ] Export functionality (PDF, BibTeX)
- [ ] Cross-reference mapping
- [ ] Academic search patterns analytics
- [ ] Collaborative features for researchers

---

## 🛠 **Technical Stack**

### **Backend** _(Current)_

- **Database**: Supabase (PostgreSQL)
- **Functions**: 6 optimized SQL functions deployed
- **API**: Next.js API routes with TypeScript
- **Migration**: Node.js scripts with batch processing

### **Frontend** _(Planned)_

- **Framework**: Next.js 15.1+ with TypeScript
- **Styling**: Tailwind CSS + shadcn/ui components
- **State**: Zustand or React Query for caching
- **Search**: Real-time with debounced queries
- **Performance**: React Suspense + virtualization

### **Infrastructure**

- **Hosting**: Vercel for frontend, Supabase for backend
- **CDN**: Vercel Edge Network
- **Analytics**: Vercel Analytics + Supabase Analytics
- **Monitoring**: Error boundaries with detailed context

---

## 📊 **Success Metrics**

### **Performance Targets**

- **Search Response**: < 500ms for 50,000+ text segments
- **Page Load**: < 2.5s LCP for commentary pages
- **Database Queries**: < 100ms for optimized functions
- **Mobile Performance**: 90+ Lighthouse score

### **User Experience Goals**

- **Search Accuracy**: Relevant results with proper ranking
- **Navigation Speed**: Instant tree expansion/collapse
- **Reading Flow**: Seamless cross-reference navigation
- **Accessibility**: WCAG 2.1 AA compliance

### **Scholarly Requirements**

- **Data Integrity**: 100% preservation of original commentary text
- **Citation Accuracy**: Proper attribution and linking
- **Academic Standards**: Peer-review ready interface
- **Research Support**: Advanced filtering and analysis tools

---

## 🔗 **Key Resources**

### **Documentation**

- [Frontend Specifications](./FRONTEND_SPECIFICATIONS.md) - Complete UI/UX requirements
- [Migration Guide](./MIGRATION_GUIDE.md) - Database migration procedures
- [Original README Files](./README-Files/) - Dartmouth system documentation

### **Code Structure**

- `supabase/migrations/` - Database schema and functions
- `api/` - Next.js API routes
- `scripts/` - Migration and utility scripts
- `lib/` - Shared parsers and helpers

### **External Resources**

- [Dartmouth Dante Project](https://dante.dartmouth.edu/) - Original system
- [Supabase Docs](https://supabase.com/docs) - Database platform
- [Next.js 15.1 Docs](https://nextjs.org/docs) - Frontend framework

---

_Last Updated: 2025-08-19 | Status: Migration Phase - Fixing `doc_id` uniqueness_
