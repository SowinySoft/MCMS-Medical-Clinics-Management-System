import { test, expect, type Page } from "@playwright/test";

/**
 * Authentication & session flows.
 *
 * Assertions use stable signals: localStorage keys, the .mcms-input /
 * input[type=password] / submit-button (role=button,name=/login/) DOM hooks,
 * and url regexes — NOT localized strings (robust to EN/AR toggle).
 */
const API = "http://127.0.0.1:8010/api";

async function apiLogin(page: Page, username: string, password: string) {
  return page.evaluate(
    async ({ api, u, p }) => {
      const r = await fetch(`${api}/auth/token/`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username: u, password: p }),
      });
      if (!r.ok) throw new Error(`login failed: ${r.status}`);
      const j = await r.json();
      localStorage.setItem("access", j.access);
      localStorage.setItem("refresh", j.refresh);
      return j.access as string;
    },
    { api: API, u: username, p: password }
  );
}

test.beforeEach(async ({ page }) => {
  await page.goto("/login");
  await expect(page).toHaveURL(/login/);
});

test("login form renders with prefilled admin credentials", async ({ page }) => {
  await expect(page.locator("input.mcms-input").first()).toBeVisible();
  await expect(page.locator('input[type="password"]')).toBeVisible();
  // username + password are prefilled in the component state
  await expect(page.locator("input.mcms-input").first()).toHaveValue("admin");
  await expect(page.locator('input[type="password"]')).toHaveValue("admin123");
  await expect(page.getByRole("button", { name: /login/i })).toBeVisible();
});

test("valid login stores JWT and routes to dashboard", async ({ page }) => {
  await page.getByRole("button", { name: /login/i }).click();
  await expect
    .poll(async () => page.evaluate(() => !!localStorage.getItem("access")), { timeout: 15_000 })
    .toBeTruthy();
  await expect(page).toHaveURL(/\/(dashboard)?$/);
  await expect(page.getByRole("heading", { name: /dashboard/i })).toBeVisible();
});

test("invalid credentials show an error and stay on /login", async ({ page }) => {
  await page.locator("input.mcms-input").first().fill("admin");
  await page.locator('input[type="password"]').fill("wrong-password");
  await page.getByRole("button", { name: /login/i }).click();
  // error message appears; we stay on /login (no access token set)
  await expect(page.locator("div").filter({ hasText: /invalid/i }).first()).toBeVisible({ timeout: 10_000 });
  await expect(page).toHaveURL(/login/);
  await expect(page.evaluate(() => !!localStorage.getItem("access"))).resolves.toBe(false);
});

test("logout clears the session and returns to /login", async ({ page }) => {
  await apiLogin(page, "admin", "admin123");
  await page.goto("/");
  await expect(page.getByRole("heading", { name: /dashboard/i })).toBeVisible();
  // Sidebar logout button (role=button, name=/logout/)
  await page.getByRole("button", { name: /logout/i }).click();
  await expect
    .poll(async () => page.evaluate(() => !localStorage.getItem("access")), { timeout: 10_000 })
    .toBeTruthy();
  await expect(page).toHaveURL(/login/);
});
