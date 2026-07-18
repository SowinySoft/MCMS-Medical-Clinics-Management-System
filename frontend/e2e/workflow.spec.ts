import { test, expect, type Page } from "@playwright/test";

/**
 * Medical-workflow full-page data sweep.
 *
 * Goal: prove every navigable page renders data (or a legitimate empty state)
 * and never an error. Enumerates models from the live API root so it always
 * matches the backend (no hard-coded table list that drifts).
 *
 * - As admin: visits every top-level page + every model's TableBrowser.
 * - As acc1 (accountant): re-visits top-level pages to confirm RBAC-gated
 *   pages still render (not 500) and admin-only buttons are hidden.
 *
 * Any page that shows .mcms-error is collected and reported; the test fails
 * with the full list at the end.
 */

const API = process.env.E2E_API || "http://127.0.0.1:8010/api";
const BASE = process.env.E2E_BASE || "http://127.0.0.1:8010";

// Schemas that are action-only services (not table-backed) — skip the per-model
// browser for these (they have no DRF list view).
const ACTION_ONLY_SCHEMAS = new Set([
  "terminology",
  "telemed",
  "payer",
  "identity",
  "fhir",
  "hl7v2",
  "ai",
  "referral",
]);

interface Creds { username: string; password: string; }

async function login(page: Page, creds: Creds) {
  await page.goto(`${BASE}/login`);
  await page.evaluate(async (args: { api: string; creds: Creds }) => {
    const { api, creds } = args;
    const r = await fetch(`${api}/auth/token/`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username: creds.username, password: creds.password }),
    });
    if (!r.ok) throw new Error(`login failed: ${r.status}`);
    const j = await r.json();
    // mirror what the app's AuthProvider.login() stores
    const payload = JSON.parse(atob(j.access.split(".")[1]));
    localStorage.setItem("access", j.access);
    localStorage.setItem("refresh", j.refresh);
    localStorage.setItem("roles", JSON.stringify(payload.roles || []));
    localStorage.setItem("perms", JSON.stringify(payload.perms || []));
  }, { api: API, creds });
  await page.goto(`${BASE}/`);
  await expect(page.getByRole("heading", { name: /dashboard/i })).toBeVisible();
}

async function gotoModel(page: Page, schema: string, model: string) {
  await page.goto(`${BASE}/browse/${schema}/${model}`);
  // wait for the table browser to finish loading (spinner clears)
  await expect(page.locator(".mcms-spinner")).toHaveCount(0, { timeout: 20_000 });
}

/** Assert a page is not in an error state. Returns the error text if errored. */
async function errorOn(page: Page): Promise<string | null> {
  const err = page.locator(".mcms-error").first();
  if (await err.count()) {
    return (await err.innerText()).slice(0, 200);
  }
  return null;
}

test.describe("medical workflow — full page data sweep", () => {
  test("admin: every model page renders data or empty (never error)", async ({ page, request }) => {
    await login(page, { username: "admin", password: "admin123" });

    // Enumerate models from the live API root (authenticated, same origin).
    const data: Record<string, string> = await page.evaluate(async (api) => {
      const token = localStorage.getItem("access");
      const r = await fetch(`${api}/`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!r.ok) throw new Error(`api root ${r.status}`);
      return r.json();
    }, API);

    // Build schema -> [model slugs]. The API root uses slash-separated keys
    // (e.g. "core/address"); the SPA's SchemaBrowser filters on `${slug}/`.
    // Reconstruct the URL schema as mcms_${slug} to match /browse/:schema/:model.
    const bySchema = new Map<string, string[]>();
    for (const key of Object.keys(data)) {
      const slash = key.indexOf("/");
      if (slash < 0) continue;
      const schemaSlug = key.slice(0, slash);
      if (ACTION_ONLY_SCHEMAS.has(schemaSlug)) continue;
      const schema = `mcms_${schemaSlug}`;
      const model = key.slice(slash + 1);
      if (!bySchema.has(schema)) bySchema.set(schema, []);
      bySchema.get(schema)!.push(model);
    }

    const failures: string[] = [];
    const emptyOk: string[] = [];
    const dataOk: string[] = [];
    const apiBad: string[] = [];

    for (const [schema, models] of bySchema) {
      const slug = schema.replace(/^mcms_/, "");
      for (const model of models) {
        await gotoModel(page, schema, model);
        const e = await errorOn(page);
        if (e) {
          failures.push(`${schema}/${model}: ERROR ${e}`);
          continue;
        }
        // either a data table rendered, or a legitimate empty state
        const hasTable = await page.locator("table tbody tr").count();
        const hasEmpty = await page.locator(".mcms-empty").count();
        if (hasTable > 0) {
          dataOk.push(`${schema}/${model}`);
        } else if (hasEmpty > 0) {
          // Confirm the backend actually returns 200 with empty (not a 500 the
          // SPA quietly rendered as empty).
          const status = await page.evaluate(
            async (args: { api: string; slug: string; model: string }) => {
              const token = localStorage.getItem("access");
              const r = await fetch(`${args.api}/${args.slug}/${args.model}/`, {
                headers: { Authorization: `Bearer ${token}` },
              });
              return r.status;
            },
            { api: API, slug, model }
          );
          if (status >= 400) apiBad.push(`${schema}/${model}: API ${status}`);
          else emptyOk.push(`${schema}/${model}`);
        } else {
          failures.push(`${schema}/${model}: NEITHER table NOR empty-state`);
        }
      }
    }

    // Report. Empty states are acceptable (no seed data); errors are not.
    console.log(`\n=== SWEEP SUMMARY (admin) ===`);
    console.log(`data pages : ${dataOk.length}`);
    console.log(`empty pages: ${emptyOk.length}`);
    console.log(`api-bad    : ${apiBad.length}`);
    console.log(`failures   : ${failures.length}`);
    if (emptyOk.length) console.log("EMPTY: " + emptyOk.join(", "));
    if (apiBad.length) console.log("API-BAD: " + apiBad.join(", "));
    if (failures.length) {
      console.log("FAILURES:\n" + failures.join("\n"));
      throw new Error(`Sweep found ${failures.length} failing pages:\n` + failures.join("\n"));
    }
    if (apiBad.length) {
      throw new Error(`Sweep found ${apiBad.length} models with API error:\n` + apiBad.join("\n"));
    }
  });

  test("admin: top-level workflow pages render without error", async ({ page }) => {
    await login(page, { username: "admin", password: "admin123" });
    const pages: [string, string][] = [
      ["/", "Dashboard"],
      ["/reports", "Reports"],
      ["/portal", "Patient Portal"],
      ["/monitors", "Monitors"],
      ["/vital", "Vital Records"],
      ["/sysadmin", "System"],
    ];
    const failures: string[] = [];
    for (const [path, name] of pages) {
      await page.goto(`${BASE}${path}`);
      await expect(page.locator(".mcms-spinner")).toHaveCount(0, { timeout: 20_000 });
      const e = await errorOn(page);
      if (e) failures.push(`${name} (${path}): ${e}`);
      else console.log(`OK top-level: ${name}`);
    }
    if (failures.length) throw new Error("Top-level failures:\n" + failures.join("\n"));
  });

  test("accountant (acc1): RBAC-gated pages render, admin-only hidden", async ({ page }) => {
    await login(page, { username: "acc1", password: "acc1123" });

    // admin-only buttons must be hidden
    await expect(page.getByRole("button", { name: /^System$/ })).toHaveCount(0);
    await expect(page.getByRole("button", { name: /^Monitors$/ })).toHaveCount(0);
    await expect(page.getByRole("button", { name: /^Vital Records$/ })).toHaveCount(0);

    // pages acc1 CAN reach must not 500/error
    const pages: [string, string][] = [
      ["/", "Dashboard"],
      ["/reports", "Reports"],
      ["/portal", "Patient Portal"],
    ];
    const failures: string[] = [];
    for (const [path, name] of pages) {
      await page.goto(`${BASE}${path}`);
      await expect(page.locator(".mcms-spinner")).toHaveCount(0, { timeout: 20_000 });
      const e = await errorOn(page);
      if (e) failures.push(`${name} (${path}): ${e}`);
      else console.log(`OK acc1: ${name}`);
    }
    if (failures.length) throw new Error("acc1 failures:\n" + failures.join("\n"));
  });
});
