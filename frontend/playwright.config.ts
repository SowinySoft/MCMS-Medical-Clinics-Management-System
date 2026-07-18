import { defineConfig, devices } from "@playwright/test";

/**
 * Frontend e2e smoke test config.
 *
 * Django serves BOTH the built SPA (from frontend/dist, at /) and the API
 * (at /api) on :8010 — this mirrors the single-service miget deploy. The
 * Django server is started externally before `playwright test` (the CI
 * `frontend-e2e` job and the local dev flow both do this), so Playwright does
 * not own a webServer; it just drives the browser against :8010.
 */
export default defineConfig({
  testDir: "./e2e",
  timeout: 60_000,
  expect: { timeout: 15_000 },
  fullyParallel: false,
  retries: 0,
  reporter: [["list"]],
  use: {
    baseURL: "http://localhost:8010",
    headless: true,
    trace: "on-first-retry",
  },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
  ],
});
