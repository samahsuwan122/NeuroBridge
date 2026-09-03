import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// NeuroBridge web dashboard dev server.
// Runs on http://localhost:5173, which the backend CORS allowlist already
// permits (see backend CORS_ORIGINS). The API base URL can be overridden with
// VITE_API_BASE_URL (defaults to http://localhost:8000).
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    host: true,
  },
});
