import { test, expect } from "@playwright/test";

/**
 * Navigation, theming, i18n (RTL) and RBAC-gated controls.
 *
 * Uses stable signals: the .mcms-select theme control, the language toggle
 * button (text "EN / ع"), document.documentElement.dir / data-theme, the
 * sidebar schema buttons (text = schema minus "mcms_"), and the presence /
 * absence of topbar nav buttons (name matched by regex, language-independent).
 */
const API = "http://127.0.0.1:8010/api";

async function login(page: import("@playwright/test").Page) {
  await page.goto("/login");
  await page.evaluate(async (api) => {
    const r = await fetch(`${api}/auth/token/`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username: "admin", password: "admin123" }),
    });
    if (!r.ok) throw new Error(`login failed: ${r.status}`);
    const j = await r.json();
    // mirror what the app's AuthProvider.login() stores
    const payload = JSON.parse(atob(j.access.split(".")[1]));
    localStorage.setItem("access", j.access);
    localStorage.setItem("refresh", j.refresh);
    localStorage.setItem("roles", JSON.stringify(payload.roles || []));
    localStorage.setItem("perms", JSON.stringify(payload.perms || []));
  }, API);
  await page.goto("/");
  await expect(page.getByRole("heading", { name: /dashboard/i })).toBeVisible();
}

test("theme switcher changes the applied palette (data-theme)", async ({ page }) => {
  await login(page);
  const sel = page.locator("select.mcms-select");
  await expect(sel).toBeVisible();
  // default applied theme
  await expect(page.evaluate(() => document.documentElement.getAttribute("data-theme"))).resolves.toBe("clinical");
  await sel.selectOption("light");
  await expect(page.evaluate(() => document.documentElement.getAttribute("data-theme"))).resolves.toBe("light");
  await sel.selectOption("contrast");
  await expect(page.evaluate(() => document.documentElement.getAttribute("data-theme"))).resolves.toBe("contrast");
});

test("language toggle switches to RTL (document.dir)", async ({ page }) => {
  await login(page);
  const toggle = page.getByRole("button", { name: /EN \/ ع|ع \/ EN/i });
  await expect(toggle).toBeVisible();
  await expect(page.evaluate(() => document.documentElement.dir)).resolves.toBe("ltr");
  await toggle.click();
  await expect(page.evaluate(() => document.documentElement.dir)).resolves.toBe("rtl");
  await expect(page.evaluate(() => document.documentElement.lang)).resolves.toBe("ar");
});

test("sidebar lists schema groups and a schema button navigates to the browser", async ({ page }) => {
  await login(page);
  // sidebar group title + at least one schema button
  await expect(page.getByText(/Departments & Modules/i)).toBeVisible();
  const hrBtn = page.getByRole("button", { name: /^hr$/ });
  await expect(hrBtn).toBeAttached();
  await hrBtn.click();
  await expect(page).toHaveURL(/\/browse\/hr$/);
  // schema browser shows a model-card grid (.mcms-card) or empty state
  await expect(page.locator(".mcms-spinner")).toHaveCount(0, { timeout: 15_000 });
  await expect(
    page.locator(".mcms-card").first().or(page.locator(".mcms-empty").first())
  ).toBeVisible({ timeout: 15_000 });
});

test("clicking a model card opens the table browser and loads rows", async ({ page }) => {
  await login(page);
  await page.goto("/browse/mcms_core");
  await expect(page.locator(".mcms-spinner")).toHaveCount(0, { timeout: 15_000 });
  // open the first model card
  await page.locator(".mcms-card").first().click();
  await expect(page).toHaveURL(/\/browse\/mcms_core\/.+/);
  // table browser: spinner clears; either rows (<table>) or empty state
  await expect(page.locator(".mcms-spinner")).toHaveCount(0, { timeout: 15_000 });
  await expect(
    page.locator("table").first().or(page.locator(".mcms-empty").first())
  ).toBeVisible({ timeout: 15_000 });
});

test("RBAC: admin sees System/Monitors/Vital Records; accountant does not", async ({ page }) => {
  // admin (sysadmin) sees the admin-only nav buttons
  await login(page);
  await expect(page.getByRole("button", { name: /^System$/ })).toBeVisible();
  await expect(page.getByRole("button", { name: /^Monitors$/ })).toBeVisible();
  await expect(page.getByRole("button", { name: /^Vital Records$/ })).toBeVisible();

  // accountant (acc1) does NOT see them
  await page.evaluate(async (api) => {
    const r = await fetch(`${api}/auth/token/`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username: "acc1", password: "acc1123" }),
    });
    if (!r.ok) throw new Error(`login failed: ${r.status}`);
    const j = await r.json();
    const payload = JSON.parse(atob(j.access.split(".")[1]));
    localStorage.setItem("access", j.access);
    localStorage.setItem("refresh", j.refresh);
    localStorage.setItem("roles", JSON.stringify(payload.roles || []));
    localStorage.setItem("perms", JSON.stringify(payload.perms || []));
  }, API);
  await page.goto("/");
  await expect(page.getByRole("heading", { name: /dashboard/i })).toBeVisible();
  await expect(page.getByRole("button", { name: /^System$/ })).toHaveCount(0);
  await expect(page.getByRole("button", { name: /^Monitors$/ })).toHaveCount(0);
  await expect(page.getByRole("button", { name: /^Vital Records$/ })).toHaveCount(0);
  // but accountant (billing.read) still sees the billing schema group
  await expect(page.getByRole("button", { name: /^billing$/ })).toBeVisible();
});

test("medical waste schema group is navigable and reaches the backend", async ({ page }) => {
  await login(page);
  // the waste schema button lives under the Management & Support group
  const wasteBtn = page.getByRole("button", { name: /^waste$/ });
  await expect(wasteBtn).toBeAttached();
  await wasteBtn.click();
  await expect(page).toHaveURL(/\/browse\/waste$/);
  await expect(page.locator(".mcms-spinner")).toHaveCount(0, { timeout: 15_000 });
  await expect(
    page.locator(".mcms-card").first().or(page.locator(".mcms-empty").first())
  ).toBeVisible({ timeout: 15_000 });
  // open the disposal manifests model — exercises the new CRUD endpoint
  const manifestCard = page.getByRole("button", { name: /Disposal Manifests/i }).first();
  await expect(manifestCard).toBeVisible({ timeout: 15_000 });
  await manifestCard.click();
  await expect(page).toHaveURL(/\/browse\/waste\/waste-disposal-manifest$/);
  await expect(page.locator(".mcms-spinner")).toHaveCount(0, { timeout: 15_000 });
  await expect(
    page.locator("table").first().or(page.locator(".mcms-empty").first())
  ).toBeVisible({ timeout: 15_000 });
});
