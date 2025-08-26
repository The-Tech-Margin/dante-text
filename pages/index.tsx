import Head from "next/head";
import { useState } from "react";

interface ApiResult {
  results: any[];
  count: number;
  query?: string;
  [key: string]: any;
}

export default function Home() {
  const [loading, setLoading] = useState<string | null>(null);
  const [result, setResult] = useState<ApiResult | null>(null);
  const [error, setError] = useState<string | null>(null);

  const runSampleQuery = async (
    endpoint: string,
    payload: object,
    description: string
  ) => {
    setLoading(description);
    setError(null);
    setResult(null);

    try {
      const response = await fetch(endpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || `HTTP ${response.status}`);
      }

      setResult(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unknown error");
    } finally {
      setLoading(null);
    }
  };

  return (
    <div>
      <Head>
        <title>Dante Text API</title>
        <meta
          name="description"
          content="API for accessing Dante commentary data"
        />
      </Head>

      <main
        style={{
          padding: "2rem",
          maxWidth: "1200px",
          margin: "0 auto",
          fontFamily: "system-ui, sans-serif",
        }}
      >
        <h1 style={{ color: "#8B5A3C", marginBottom: "1rem" }}>
          Dante Text API
        </h1>

        <p
          style={{
            fontSize: "1.1rem",
            marginBottom: "2rem",
            lineHeight: "1.6",
          }}
        >
          This API provides access to both current (DDP) and historical
          (Alexandria Archive) Dante commentary data from the Dartmouth Dante
          Project.
        </p>

        <div
          style={{
            display: "grid",
            gridTemplateColumns: "1fr 1fr",
            gap: "2rem",
            marginBottom: "2rem",
          }}
        >
          <div>
            <h2 style={{ color: "#8B5A3C" }}>Try Sample Queries</h2>

            <div
              style={{
                display: "flex",
                flexDirection: "column",
                gap: "0.5rem",
              }}
            >
              <button
                onClick={() =>
                  runSampleQuery(
                    "/api/ddp/search-commentaries",
                    {
                      search_term: "beatrice",
                      cantica_filter: "paradiso",
                      result_limit: 5,
                    },
                    'Search for "Beatrice" in Paradiso'
                  )
                }
                disabled={!!loading}
                style={{
                  padding: "0.75rem 1rem",
                  background:
                    loading === 'Search for "Beatrice" in Paradiso'
                      ? "#ccc"
                      : "#8B5A3C",
                  color: "white",
                  border: "none",
                  borderRadius: "4px",
                  cursor: loading ? "not-allowed" : "pointer",
                  fontSize: "0.9rem",
                }}
              >
                {loading === 'Search for "Beatrice" in Paradiso'
                  ? "Loading..."
                  : 'Search for "Beatrice" in Paradiso'}
              </button>

              <button
                onClick={() =>
                  runSampleQuery(
                    "/api/alexandria/compare-versions",
                    {
                      commentary_name: "Scartazzini",
                    },
                    "Compare Scartazzini versions"
                  )
                }
                disabled={!!loading}
                style={{
                  padding: "0.75rem 1rem",
                  background:
                    loading === "Compare Scartazzini versions"
                      ? "#ccc"
                      : "#8B5A3C",
                  color: "white",
                  border: "none",
                  borderRadius: "4px",
                  cursor: loading ? "not-allowed" : "pointer",
                  fontSize: "0.9rem",
                }}
              >
                {loading === "Compare Scartazzini versions"
                  ? "Loading..."
                  : "Compare Scartazzini versions"}
              </button>

              <button
                onClick={() =>
                  runSampleQuery(
                    "/api/ddp/find-passages",
                    {
                      cantica: "inferno",
                      canto: 1,
                      start_line: 1,
                      end_line: 10,
                    },
                    "Find Inferno Canto 1, lines 1-10"
                  )
                }
                disabled={!!loading}
                style={{
                  padding: "0.75rem 1rem",
                  background:
                    loading === "Find Inferno Canto 1, lines 1-10"
                      ? "#ccc"
                      : "#8B5A3C",
                  color: "white",
                  border: "none",
                  borderRadius: "4px",
                  cursor: loading ? "not-allowed" : "pointer",
                  fontSize: "0.9rem",
                }}
              >
                {loading === "Find Inferno Canto 1, lines 1-10"
                  ? "Loading..."
                  : "Find Inferno Canto 1, lines 1-10"}
              </button>

              <button
                onClick={() =>
                  runSampleQuery(
                    "/api/unified/search-all-texts",
                    {
                      search_term: "divine love",
                      include_historical: true,
                      include_current: true,
                      result_limit: 8,
                    },
                    'Unified search for "divine love"'
                  )
                }
                disabled={!!loading}
                style={{
                  padding: "0.75rem 1rem",
                  background:
                    loading === 'Unified search for "divine love"'
                      ? "#ccc"
                      : "#8B5A3C",
                  color: "white",
                  border: "none",
                  borderRadius: "4px",
                  cursor: loading ? "not-allowed" : "pointer",
                  fontSize: "0.9rem",
                }}
              >
                {loading === 'Unified search for "divine love"'
                  ? "Loading..."
                  : 'Unified search for "divine love"'}
              </button>
            </div>
          </div>

          <div>
            <h2 style={{ color: "#8B5A3C" }}>Documentation</h2>
            <div
              style={{
                display: "flex",
                flexDirection: "column",
                gap: "0.5rem",
              }}
            >
              <a
                href="/DANTE_API_DOCUMENTATION.md"
                target="_blank"
                style={{
                  padding: "0.75rem 1rem",
                  background: "#f8f9fa",
                  color: "#8B5A3C",
                  textDecoration: "none",
                  border: "1px solid #8B5A3C",
                  borderRadius: "4px",
                  textAlign: "center",
                }}
              >
                📖 Complete API Documentation
              </a>
              <a
                href="/TYPESCRIPT_REFERENCE_TYPES.md"
                target="_blank"
                style={{
                  padding: "0.75rem 1rem",
                  background: "#f8f9fa",
                  color: "#8B5A3C",
                  textDecoration: "none",
                  border: "1px solid #8B5A3C",
                  borderRadius: "4px",
                  textAlign: "center",
                }}
              >
                ⚡ TypeScript Reference Types
              </a>
              <a
                href="/api-info"
                style={{
                  padding: "0.75rem 1rem",
                  background: "#f8f9fa",
                  color: "#8B5A3C",
                  textDecoration: "none",
                  border: "1px solid #8B5A3C",
                  borderRadius: "4px",
                  textAlign: "center",
                }}
              >
                🔌 Connection Information
              </a>
            </div>
          </div>
        </div>

        {/* Results Display */}
        {error && (
          <div
            style={{
              padding: "1rem",
              background: "#fee",
              color: "#c33",
              borderRadius: "4px",
              marginBottom: "1rem",
            }}
          >
            <strong>Error:</strong> {error}
          </div>
        )}

        {result && (
          <div
            style={{
              padding: "1rem",
              background: "#f8f9fa",
              borderRadius: "4px",
              marginBottom: "1rem",
            }}
          >
            <h3 style={{ color: "#8B5A3C", marginTop: 0 }}>
              Query Results ({result.count} items)
            </h3>

            {result.query && (
              <p>
                <strong>Query:</strong> "{result.query}"
              </p>
            )}

            <div
              style={{
                maxHeight: "300px",
                overflow: "auto",
                border: "1px solid #ddd",
                borderRadius: "4px",
                padding: "0.5rem",
              }}
            >
              <pre
                style={{
                  margin: 0,
                  fontSize: "0.8rem",
                  whiteSpace: "pre-wrap",
                  wordWrap: "break-word",
                }}
              >
                {JSON.stringify(result.results, null, 2)}
              </pre>
            </div>
          </div>
        )}

        <h2 style={{ color: "#8B5A3C" }}>Available Endpoints</h2>
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(250px, 1fr))",
            gap: "1rem",
          }}
        >
          <div
            style={{
              padding: "1rem",
              border: "1px solid #ddd",
              borderRadius: "4px",
            }}
          >
            <h3 style={{ margin: "0 0 0.5rem 0", color: "#8B5A3C" }}>
              Alexandria Archive
            </h3>
            <ul style={{ margin: 0, paddingLeft: "1rem", fontSize: "0.9rem" }}>
              <li>/api/alexandria/compare-versions</li>
              <li>/api/alexandria/find-variants</li>
              <li>/api/alexandria/scholarly-search</li>
              <li>/api/alexandria/commentary-network</li>
            </ul>
          </div>

          <div
            style={{
              padding: "1rem",
              border: "1px solid #ddd",
              borderRadius: "4px",
            }}
          >
            <h3 style={{ margin: "0 0 0.5rem 0", color: "#8B5A3C" }}>
              DDP Current
            </h3>
            <ul style={{ margin: 0, paddingLeft: "1rem", fontSize: "0.9rem" }}>
              <li>/api/ddp/search-commentaries</li>
              <li>/api/ddp/find-passages</li>
              <li>/api/ddp/commentary-stats</li>
            </ul>
          </div>

          <div
            style={{
              padding: "1rem",
              border: "1px solid #ddd",
              borderRadius: "4px",
            }}
          >
            <h3 style={{ margin: "0 0 0.5rem 0", color: "#8B5A3C" }}>
              Unified Search
            </h3>
            <ul style={{ margin: 0, paddingLeft: "1rem", fontSize: "0.9rem" }}>
              <li>/api/unified/search-all-texts</li>
              <li>/api/unified/compare-versions</li>
              <li>/api/unified/find-variants</li>
            </ul>
          </div>
        </div>

        <div
          style={{
            marginTop: "2rem",
            padding: "1rem",
            background: "#f0f8ff",
            borderRadius: "4px",
          }}
        >
          <h3 style={{ margin: "0 0 0.5rem 0", color: "#8B5A3C" }}>
            Security & Performance
          </h3>
          <ul style={{ fontSize: "0.9rem", lineHeight: "1.5" }}>
            <li>
              🔒 All endpoints are <strong>read-only</strong> with input
              validation
            </li>
            <li>⚡ Rate limited to 30 requests per minute per IP</li>
            <li>🛡️ CORS enabled for cross-origin requests</li>
            <li>📊 Results limited to prevent excessive data transfer</li>
          </ul>
        </div>
      </main>
    </div>
  );
}
