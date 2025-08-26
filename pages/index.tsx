import Head from "next/head";

export default function Home() {
  return (
    <div>
      <Head>
        <title>Dante Text API</title>
        <meta
          name="description"
          content="API for accessing Dante commentary data"
        />
      </Head>

      <main style={{ padding: "2rem", maxWidth: "800px", margin: "0 auto" }}>
        <h1>Dante Text API</h1>

        <p>
          This API provides access to both current (DDP) and historical
          (Alexandria Archive) Dante commentary data from the Dartmouth Dante
          Project.
        </p>

        <h2>API Documentation</h2>
        <p>
          For complete API documentation, see:{" "}
          <a href="/DANTE_API_DOCUMENTATION.md" target="_blank">
            API Documentation
          </a>
        </p>

        <h2>Available Endpoints</h2>
        <ul>
          <li>
            <strong>Alexandria Archive:</strong> /api/alexandria/*
          </li>
          <li>
            <strong>DDP Current:</strong> /api/ddp/*
          </li>
          <li>
            <strong>Unified Search:</strong> /api/unified/*
          </li>
        </ul>

        <h2>Example Usage</h2>
        <pre
          style={{
            background: "#f5f5f5",
            padding: "1rem",
            borderRadius: "4px",
          }}
        >
          {`POST /api/ddp/search-commentaries
Content-Type: application/json

{
  "search_term": "beatrice",
  "cantica_filter": "paradiso"
}`}
        </pre>
      </main>
    </div>
  );
}
