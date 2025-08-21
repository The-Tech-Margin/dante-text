# Dante Frontend Implementation Plan

This document outlines the strategy for implementing the frontend components that consume the project's backend API. It serves as a blueprint for working with AI coding assistants to ensure all backend functions are correctly and completely implemented.

## 1. Backend-to-Frontend Mapping

The following table maps each backend SQL function to its corresponding API endpoint and the target frontend component(s). This checklist should be updated as development progresses.

| Backend Function                  | API Endpoint                         | Frontend Component/Hook                                             | Status        |
| --------------------------------- | ------------------------------------ | ------------------------------------------------------------------- | ------------- |
| `search_commentaries_ranked`      | `POST /api/search/commentaries`      | `components/GlobalSearchBar.tsx`, `hooks/useSearch.ts`              | `Not Started` |
| `search_texts_with_context`       | `POST /api/search/texts`             | `components/TextSearchResults.tsx`                                  | `Not Started` |
| `search_with_highlights`          | `POST /api/search/highlights`        | `components/HighlightedResult.tsx`                                  | `Not Started` |
| `get_commentary_stats`            | `GET /api/commentary/[id]/stats`     | `app/commentary/[id]/page.tsx`, `components/CommentaryStats.tsx`    | `Not Started` |
| `compare_commentaries_by_passage` | `POST /api/analysis/compare-passage` | `components/PassageComparison.tsx`, `hooks/usePassageComparison.ts` | `Not Started` |
| `get_navigation_tree`             | `GET /api/navigation/tree`           | `app/commentary/[id]/page.tsx`, `components/NavigationTree.tsx`     | `Not Started` |

---

## 2. AI Prompting Strategy

To ensure the AI generates accurate and useful code, follow the "One Function, One Prompt" rule. Each prompt should be highly specific and provide all necessary context.

### Prompting Best Practices:

1.  **State the Goal Clearly:** Begin with a high-level objective for the feature.
2.  **Provide the API Contract:** Include the exact endpoint, method, and request/response shapes from `INTEGRATION_GUIDE.md`.
3.  **Include TypeScript Types:** Copy the relevant TypeScript interfaces directly into the prompt. This is critical for generating type-safe code.
4.  **Specify UI/Styling Requirements:** Reference the design system and specific CSS classes from `FRONTEND_SPECIFICATIONS.md`.
5.  **Define Technical Constraints:** Mention the required libraries (e.g., React Query, Zustand), state management patterns (loading, error, success), and desired file structure.

### Example Prompt Template

Here is a complete, context-rich prompt for implementing the "Passage Comparison" feature. Use this as a template for other features.

---

**<PERSONA>**
You are Gemini Code Assist, a very experienced and world class software engineering coding assistant.

**<OBJECTIVE>**
Create a React hook and a corresponding component to implement the "Passage Comparison" feature for the Dante Commentary Platform.

**<CONTEXT>**

**1. Feature Goal:**
The user should be able to select a cantica, canto, and line range to see how different commentaries cover that specific passage.

**2. API Endpoint Details (from `INTEGRATION_GUIDE.md`):**

- **Endpoint:** `POST /api/analysis/compare-passage`
- **Request Body:**
  ```json
  {
    "cantica": "inferno",
    "canto": 1,
    "start_line": 1,
    "end_line": 10
  }
  ```

**3. Relevant TypeScript Types (from `INTEGRATION_GUIDE.md`):**

```typescript
// types/dante.ts
export type CanticaType = "inferno" | "purgatorio" | "paradiso" | "general";

export interface PassageComparison {
  commentary_info: Partial<Commentary>;
  text_segments: TextResult[];
  coverage_score: number;
  total_segments: number;
}

export interface TextResult {
  id: string;
  doc_id: string;
  cantica: CanticaType;
  canto_id: number;
  start_line: number;
  end_line: number;
  text_language: string;
  text_type: string;
  content: string;
}

export interface Commentary {
  id: string;
  comm_id: string;
  comm_name: string;
  comm_author: string;
  comm_lang: string;
  comm_pub_year?: string;
}
```

**4. UI/Styling Specifications (from `FRONTEND_SPECIFICATIONS.md`):**

- The component should use the TTM Dark Mode Design System.
- Each result panel should be styled with the `.ttm-comparison-panel` class.
- The coverage score should use the `.ttm-coverage-score` class.
- Use the `.ttm-btn-primary` for the "Compare" button.
- Use `.ttm-input` for form inputs.

**5. Technical Requirements:**

- Create a custom hook in `hooks/usePassageComparison.ts`.
- This hook should use `fetch` to call the API and manage `loading`, `error`, and `data` states.
- Create a client component in `components/PassageComparison.tsx`.
- The component must include a form to input `cantica`, `canto`, `start_line`, and `end_line`.
- Use the hook to fetch and display the comparison data.
- Implement loading and error states (e.g., show a "Loading..." message or an error alert).

**</CONTEXT>**

**<INPUT>**
Please generate the code for `hooks/usePassageComparison.ts` and `components/PassageComparison.tsx`.

---

## 3. Verification and Validation

After the AI generates the code for a feature:

1.  **Code Review:** Manually inspect the generated files.
    - Does the hook call the correct API endpoint?
    - Are the request and response payloads handled according to the TypeScript types?
    - Are loading and error states implemented correctly?
    - Does the component's styling match the `FRONTEND_SPECIFICATIONS.md`?
2.  **Testing:**
    - **Manual:** Run the application and test the feature with valid and invalid inputs.
    - **Automated:** Write unit tests for the hook to mock the API response and verify its state transitions. Write component tests to ensure the UI renders correctly for all states (loading, success, error).
