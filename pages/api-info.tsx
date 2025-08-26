import Head from "next/head";
import { useState } from "react";

export default function ApiInfo() {
  const [activeTab, setActiveTab] = useState("overview");

  const baseUrl =
    process.env.NODE_ENV === "production"
      ? "https://dante-api.thetechmargin.com"
      : "http://localhost:3000";

  const tabStyle = (tab: string) => ({
    padding: "0.75rem 1.5rem",
    backgroundColor: activeTab === tab ? "#0070f3" : "#f5f5f5",
    color: activeTab === tab ? "white" : "#333",
    border: "none",
    borderRadius: "8px 8px 0 0",
    cursor: "pointer",
    fontWeight: activeTab === tab ? "bold" : "normal",
  });

  return (
    <div>
      <Head>
        <title>Dante Text API - Connection Guide</title>
        <meta
          name="description"
          content="Complete guide to connecting to the Dante Text API"
        />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main style={{ maxWidth: "1200px", margin: "0 auto", padding: "2rem" }}>
        <header style={{ textAlign: "center", marginBottom: "3rem" }}>
          <h1
            style={{ fontSize: "3rem", marginBottom: "1rem", color: "#0070f3" }}
          >
            Dante Text API
          </h1>
          <p style={{ fontSize: "1.2rem", color: "#666" }}>
            Access historical and current Dante commentary data from the
            Dartmouth Dante Project
          </p>
        </header>

        <div style={{ marginBottom: "2rem" }}>
          <nav style={{ display: "flex", gap: "0.5rem" }}>
            <button
              style={tabStyle("overview")}
              onClick={() => setActiveTab("overview")}
            >
              Overview
            </button>
            <button
              style={tabStyle("quickstart")}
              onClick={() => setActiveTab("quickstart")}
            >
              Quick Start
            </button>
            <button
              style={tabStyle("endpoints")}
              onClick={() => setActiveTab("endpoints")}
            >
              Endpoints
            </button>
            <button
              style={tabStyle("examples")}
              onClick={() => setActiveTab("examples")}
            >
              Examples
            </button>
            <button
              style={tabStyle("auth")}
              onClick={() => setActiveTab("auth")}
            >
              Authentication
            </button>
          </nav>
        </div>

        <div
          style={{
            backgroundColor: "#f9f9f9",
            padding: "2rem",
            borderRadius: "0 8px 8px 8px",
          }}
        >
          {activeTab === "overview" && (
            <div>
              <h2>API Overview</h2>
              <p>
                The Dante Text API provides access to both current (DDP) and
                historical (Alexandria Archive) commentary data through a
                RESTful interface. All endpoints return JSON and use POST
                requests for complex queries.
              </p>

              <div
                style={{
                  display: "grid",
                  gridTemplateColumns: "repeat(auto-fit, minmax(300px, 1fr))",
                  gap: "2rem",
                  marginTop: "2rem",
                }}
              >
                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1.5rem",
                    borderRadius: "8px",
                    boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
                  }}
                >
                  <h3 style={{ color: "#0070f3" }}>🏛️ Alexandria Archive</h3>
                  <p>
                    Historical commentary versions from the original Dartmouth
                    Dante Project archive.
                  </p>
                  <ul>
                    <li>Version comparisons</li>
                    <li>Textual variants</li>
                    <li>Scholarly networks</li>
                    <li>Cross-version search</li>
                  </ul>
                </div>

                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1.5rem",
                    borderRadius: "8px",
                    boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
                  }}
                >
                  <h3 style={{ color: "#0070f3" }}>📚 DDP Current</h3>
                  <p>
                    Current active commentaries from the Digital Dante Project.
                  </p>
                  <ul>
                    <li>Commentary search</li>
                    <li>Passage lookup</li>
                    <li>Statistics</li>
                    <li>Full-text search</li>
                  </ul>
                </div>

                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1.5rem",
                    borderRadius: "8px",
                    boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
                  }}
                >
                  <h3 style={{ color: "#0070f3" }}>🔄 Unified</h3>
                  <p>
                    Cross-system queries that span both historical and current
                    data.
                  </p>
                  <ul>
                    <li>Combined searches</li>
                    <li>Version comparisons</li>
                    <li>Variant analysis</li>
                    <li>Comprehensive results</li>
                  </ul>
                </div>
              </div>
            </div>
          )}

          {activeTab === "quickstart" && (
            <div>
              <h2>Quick Start Guide</h2>

              <h3>1. Base URL</h3>
              <div
                style={{
                  backgroundColor: "#f0f0f0",
                  padding: "1rem",
                  borderRadius: "4px",
                  fontFamily: "monospace",
                }}
              >
                {baseUrl}
              </div>

              <h3>2. Make Your First Request</h3>
              <p>Try searching for commentaries mentioning "Beatrice":</p>

              <div
                style={{
                  backgroundColor: "#1e1e1e",
                  color: "#d4d4d4",
                  padding: "1rem",
                  borderRadius: "4px",
                  fontSize: "0.9rem",
                }}
              >
                <div style={{ color: "#569cd6" }}>curl</div> -X POST {baseUrl}
                /api/ddp/search-commentaries \<br />
                &nbsp;&nbsp;-H{" "}
                <span style={{ color: "#ce9178" }}>
                  "Content-Type: application/json"
                </span>{" "}
                \<br />
                &nbsp;&nbsp;-d{" "}
                <span style={{ color: "#ce9178" }}>
                  '{JSON.stringify({ search_term: "beatrice" }, null, 2)}'
                </span>
              </div>

              <h3>3. Expected Response</h3>
              <div
                style={{
                  backgroundColor: "#f0f0f0",
                  padding: "1rem",
                  borderRadius: "4px",
                  fontSize: "0.9rem",
                }}
              >
                <pre>
                  {JSON.stringify(
                    {
                      results: [
                        {
                          commentary_name: "Scartazzini",
                          cantica: "paradiso",
                          canto_id: 31,
                          content_match: "Beatrice appears in the...",
                          relevance_score: 0.85,
                        },
                      ],
                      count: 1,
                      query: "beatrice",
                    },
                    null,
                    2
                  )}
                </pre>
              </div>

              <h3>4. Integration Libraries</h3>
              <div
                style={{
                  display: "grid",
                  gridTemplateColumns: "repeat(auto-fit, minmax(250px, 1fr))",
                  gap: "1rem",
                }}
              >
                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1rem",
                    borderRadius: "4px",
                  }}
                >
                  <strong>JavaScript/Node.js</strong>
                  <div
                    style={{
                      fontFamily: "monospace",
                      fontSize: "0.8rem",
                      marginTop: "0.5rem",
                    }}
                  >
                    fetch(), axios, node-fetch
                  </div>
                </div>
                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1rem",
                    borderRadius: "4px",
                  }}
                >
                  <strong>Python</strong>
                  <div
                    style={{
                      fontFamily: "monospace",
                      fontSize: "0.8rem",
                      marginTop: "0.5rem",
                    }}
                  >
                    requests, httpx
                  </div>
                </div>
                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1rem",
                    borderRadius: "4px",
                  }}
                >
                  <strong>React</strong>
                  <div
                    style={{
                      fontFamily: "monospace",
                      fontSize: "0.8rem",
                      marginTop: "0.5rem",
                    }}
                  >
                    React Query, SWR
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === "endpoints" && (
            <div>
              <h2>API Endpoints</h2>

              <h3 style={{ color: "#0070f3" }}>Alexandria Archive</h3>
              <div style={{ display: "grid", gap: "1rem" }}>
                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1rem",
                    borderRadius: "4px",
                  }}
                >
                  <div style={{ fontFamily: "monospace", fontWeight: "bold" }}>
                    POST /api/alexandria/compare-versions
                  </div>
                  <div style={{ color: "#666", marginTop: "0.5rem" }}>
                    Compare historical versions of a commentary
                  </div>
                </div>
                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1rem",
                    borderRadius: "4px",
                  }}
                >
                  <div style={{ fontFamily: "monospace", fontWeight: "bold" }}>
                    POST /api/alexandria/find-variants
                  </div>
                  <div style={{ color: "#666", marginTop: "0.5rem" }}>
                    Find textual variants across versions for a passage
                  </div>
                </div>
                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1rem",
                    borderRadius: "4px",
                  }}
                >
                  <div style={{ fontFamily: "monospace", fontWeight: "bold" }}>
                    POST /api/alexandria/scholarly-search
                  </div>
                  <div style={{ color: "#666", marginTop: "0.5rem" }}>
                    Search across all historical versions
                  </div>
                </div>
                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1rem",
                    borderRadius: "4px",
                  }}
                >
                  <div style={{ fontFamily: "monospace", fontWeight: "bold" }}>
                    POST /api/alexandria/commentary-network
                  </div>
                  <div style={{ color: "#666", marginTop: "0.5rem" }}>
                    Analyze scholarly relationships between commentaries
                  </div>
                </div>
              </div>

              <h3 style={{ color: "#0070f3", marginTop: "2rem" }}>
                DDP Current
              </h3>
              <div style={{ display: "grid", gap: "1rem" }}>
                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1rem",
                    borderRadius: "4px",
                  }}
                >
                  <div style={{ fontFamily: "monospace", fontWeight: "bold" }}>
                    POST /api/ddp/search-commentaries
                  </div>
                  <div style={{ color: "#666", marginTop: "0.5rem" }}>
                    Search current commentary texts
                  </div>
                </div>
                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1rem",
                    borderRadius: "4px",
                  }}
                >
                  <div style={{ fontFamily: "monospace", fontWeight: "bold" }}>
                    POST /api/ddp/find-passages
                  </div>
                  <div style={{ color: "#666", marginTop: "0.5rem" }}>
                    Find passages by cantica, canto, and line numbers
                  </div>
                </div>
                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1rem",
                    borderRadius: "4px",
                  }}
                >
                  <div style={{ fontFamily: "monospace", fontWeight: "bold" }}>
                    POST /api/ddp/commentary-stats
                  </div>
                  <div style={{ color: "#666", marginTop: "0.5rem" }}>
                    Get statistics for a specific commentary
                  </div>
                </div>
              </div>

              <h3 style={{ color: "#0070f3", marginTop: "2rem" }}>
                Unified Cross-System
              </h3>
              <div style={{ display: "grid", gap: "1rem" }}>
                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1rem",
                    borderRadius: "4px",
                  }}
                >
                  <div style={{ fontFamily: "monospace", fontWeight: "bold" }}>
                    POST /api/unified/search-all-texts
                  </div>
                  <div style={{ color: "#666", marginTop: "0.5rem" }}>
                    Search across both current and historical systems
                  </div>
                </div>
                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1rem",
                    borderRadius: "4px",
                  }}
                >
                  <div style={{ fontFamily: "monospace", fontWeight: "bold" }}>
                    POST /api/unified/compare-versions
                  </div>
                  <div style={{ color: "#666", marginTop: "0.5rem" }}>
                    Compare versions across both systems
                  </div>
                </div>
                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1rem",
                    borderRadius: "4px",
                  }}
                >
                  <div style={{ fontFamily: "monospace", fontWeight: "bold" }}>
                    POST /api/unified/find-variants
                  </div>
                  <div style={{ color: "#666", marginTop: "0.5rem" }}>
                    Find passage variants across both systems
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === "examples" && (
            <div>
              <h2>Code Examples</h2>

              <h3>JavaScript (Fetch API)</h3>
              <div
                style={{
                  backgroundColor: "#1e1e1e",
                  color: "#d4d4d4",
                  padding: "1rem",
                  borderRadius: "4px",
                  fontSize: "0.9rem",
                }}
              >
                <pre>{`const searchCommentaries = async (term) => {
  const response = await fetch('${baseUrl}/api/ddp/search-commentaries', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      search_term: term,
      cantica_filter: 'paradiso',
      result_limit: 10
    })
  });
  
  const data = await response.json();
  return data.results;
};`}</pre>
              </div>

              <h3>Python (requests)</h3>
              <div
                style={{
                  backgroundColor: "#1e1e1e",
                  color: "#d4d4d4",
                  padding: "1rem",
                  borderRadius: "4px",
                  fontSize: "0.9rem",
                }}
              >
                <pre>{`import requests

def search_commentaries(term):
    response = requests.post('${baseUrl}/api/ddp/search-commentaries', 
                           json={
                               'search_term': term,
                               'cantica_filter': 'paradiso',
                               'result_limit': 10
                           })
    return response.json()['results']`}</pre>
              </div>

              <h3>React Hook</h3>
              <div
                style={{
                  backgroundColor: "#1e1e1e",
                  color: "#d4d4d4",
                  padding: "1rem",
                  borderRadius: "4px",
                  fontSize: "0.9rem",
                }}
              >
                <pre>{`import { useState, useEffect } from 'react';

export const useCommentarySearch = (searchTerm) => {
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  
  useEffect(() => {
    const search = async () => {
      if (!searchTerm) return;
      
      setLoading(true);
      try {
        const response = await fetch('${baseUrl}/api/ddp/search-commentaries', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ search_term: searchTerm })
        });
        const data = await response.json();
        setResults(data.results);
      } finally {
        setLoading(false);
      }
    };
    
    search();
  }, [searchTerm]);
  
  return { results, loading };
};`}</pre>
              </div>
            </div>
          )}

          {activeTab === "auth" && (
            <div>
              <h2>Authentication & Limits</h2>

              <div
                style={{
                  backgroundColor: "#fff3cd",
                  border: "1px solid #ffeaa7",
                  padding: "1rem",
                  borderRadius: "4px",
                  marginBottom: "2rem",
                }}
              >
                <strong>⚠️ Public Beta:</strong> The API is currently in public
                beta with no authentication required. Rate limiting and API keys
                will be added in future versions.
              </div>

              <h3>Current Limits</h3>
              <div
                style={{
                  display: "grid",
                  gridTemplateColumns: "repeat(auto-fit, minmax(250px, 1fr))",
                  gap: "1rem",
                }}
              >
                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1rem",
                    borderRadius: "4px",
                  }}
                >
                  <strong>Rate Limit</strong>
                  <div style={{ marginTop: "0.5rem", color: "#666" }}>
                    No current limits (subject to change)
                  </div>
                </div>
                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1rem",
                    borderRadius: "4px",
                  }}
                >
                  <strong>Request Size</strong>
                  <div style={{ marginTop: "0.5rem", color: "#666" }}>
                    Max 10MB per request
                  </div>
                </div>
                <div
                  style={{
                    backgroundColor: "white",
                    padding: "1rem",
                    borderRadius: "4px",
                  }}
                >
                  <strong>Response Limit</strong>
                  <div style={{ marginTop: "0.5rem", color: "#666" }}>
                    Default limits: 20-50 results per endpoint
                  </div>
                </div>
              </div>

              <h3>Upcoming Features</h3>
              <ul
                style={{
                  backgroundColor: "white",
                  padding: "1.5rem",
                  borderRadius: "4px",
                }}
              >
                <li>
                  <strong>API Keys:</strong> Register for API access with usage
                  tracking
                </li>
                <li>
                  <strong>Rate Limiting:</strong> Tiered limits based on usage
                  plans
                </li>
                <li>
                  <strong>Webhooks:</strong> Real-time notifications for data
                  updates
                </li>
                <li>
                  <strong>GraphQL:</strong> Alternative query interface for
                  complex requests
                </li>
              </ul>

              <h3>Contact & Support</h3>
              <div
                style={{
                  backgroundColor: "white",
                  padding: "1.5rem",
                  borderRadius: "4px",
                }}
              >
                <p>For API access requests, support, or feature requests:</p>
                <ul>
                  <li>
                    <strong>Email:</strong> api-support@thetechmargin.com
                  </li>
                  <li>
                    <strong>GitHub:</strong> Issues and feature requests
                  </li>
                  <li>
                    <strong>Documentation:</strong>{" "}
                    <a href="/DANTE_API_DOCUMENTATION.md" target="_blank">
                      Complete API Docs
                    </a>
                  </li>
                </ul>
              </div>
            </div>
          )}
        </div>

        <footer
          style={{
            marginTop: "3rem",
            textAlign: "center",
            color: "#666",
            borderTop: "1px solid #eee",
            paddingTop: "2rem",
          }}
        >
          <p>
            Dante Text API - Powered by the Dartmouth Dante Project | Built by{" "}
            <a href="https://thetechmargin.com" target="_blank" rel="noopener">
              TheTechMargin
            </a>
          </p>
          <p style={{ fontSize: "0.9rem", marginTop: "1rem" }}>
            <a href="/" style={{ marginRight: "1rem" }}>
              Home
            </a>
            <a
              href="/DANTE_API_DOCUMENTATION.md"
              target="_blank"
              style={{ marginRight: "1rem" }}
            >
              Full Documentation
            </a>
            <a href="/TYPESCRIPT_REFERENCE_TYPES.md" target="_blank">
              TypeScript Types
            </a>
          </p>
        </footer>
      </main>
    </div>
  );
}
