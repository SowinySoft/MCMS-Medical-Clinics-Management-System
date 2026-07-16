import { defineConfig, devices } from "@playwright/test";

/**
 * Frontend e2e smoke test config.
 *
 * The SPA is built to dist/ and served by `vite preview` on :5173. The SPA's
 * apiBase is the absolute http://127.0.0.1:8010/api (see src/config.json), so
 * API calls go straight to the Django server on :8010 — Playwright only owns
 * the preview (static) server. The Django API must already be running (the CI
 * job starts it before `playwright test`).
 */
export default defineConfig({
  testDir: "./e2e",
  timeout: 60_000,
  expect: { timeout: 15_000 },
  fullyParallel: false,
  retries: 0,
  reporter: [["list"]],
  use: {
    baseURL: "http://localhost:5173",
    headless: true,
    trace: "on-first-retry",
  },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
  ],
  webServer: {
    command: "npx vite preview --port 5173 --strictPort",
    url: "http://localhost:5173",
    reuseExistingServer: false,
    timeout: 120_000,
  },
});
