# Unified Frontend Strategy for Scholarly Research

This document outlines the strategy for integrating the core Dante dataset (`dde_`) with the Alexandria historical archive (`alex_`) to create a rich, unified research experience.

## 1. Core Principle: The Scholarly Layer

The frontend should not treat the two datasets as separate silos. Instead, it should present a unified view where:

- The **Core `dde_` Dataset** acts as the modern, stable baseline.
- The **Alexandria `alex_` Dataset** acts as a "scholarly layer" that adds historical depth, textual variants, and relational context to the baseline.

Every feature should be designed with the question: "How can we enrich this view with historical context?"

---

## 2. Key Unified User Experiences

The following three features are critical for enabling advanced academic research and should be prioritized.

### a. Unified Search

A single search interface that queries both modern and historical texts simultaneously.

- **User Story:** "When I search for 'virtue', I want to see results from both the current published commentaries and their historical drafts or precursors from the 1991 archive, ranked by relevance."
- **Technical Approach:**
  - Create a new hook, `useUnifiedSearch`, that orchestrates calls to both `search_texts_with_context` and `alex_scholarly_search_all_versions`.
  - Define a new `UnifiedSearchResultItem` type to standardize the results from both sources.
  - The UI should clearly label each result with its version source (e.g., "Current 2024", "Original 1991").

### b. Holistic Commentary View

A commentary detail page that goes beyond displaying the current text, providing a complete historical and relational overview.

- **User Story:** "When I view the 'Benvenuto' commentary, I want to see a timeline of its versions, a graph of commentaries it influenced, and easily compare its current text to earlier drafts."
- **Technical Approach:**
  - Create a `UnifiedCommentaryView` component.
  - This component will use multiple Alexandria hooks (`useCommentaryTimeline`, `useCommentaryNetwork`, `useCommentaryVersions`) in parallel.
  - It will present the data through sub-components like `<CommentaryTimelineChart />`, `<InfluenceGraph />`, and `<VersionComparisonTable />`.

### c. Dynamic Passage Analysis

A tool that allows users to compare a specific passage (e.g., Inferno 1:1-10) not just across different commentaries, but across different _versions_ of the _same_ commentary over time.

- **User Story:** "I want to see how the commentary on Inferno Canto 5 changed between the 1991 draft and the current 2024 version for a specific author."
- **Technical Approach:**
  - Enhance the existing `usePassageVariants` hook or create a new `useUnifiedPassageAnalysis` hook.
  - This hook will fetch the modern text segment and all its historical variants from `alex_texts_historical`.
  - The UI will present a side-by-side or diff view, highlighting editorial changes and variant notes.

---

## 3. Implementation Roadmap

1.  **Update Type Definitions:** Add new "unified" interfaces to `types/alexandria.ts` to support the combined data structures.
2.  **Implement `useUnifiedSearch`:** Build the unified search hook as the first proof-of-concept for this strategy.
3.  **Build the `UnifiedCommentaryView`:** Create the main commentary page that orchestrates the various scholarly hooks.
4.  **Develop the `UnifiedPassageAnalysis` component:** Implement the deep-dive comparison tool.

By following this strategy, the frontend will transform from a simple data browser into a powerful, integrated platform for academic research.
