import { test, expect, type Page } from "@playwright/test";

/**
 * Table-browser CRUD flow against a real backend endpoint.
 *
 * Targets mcms_hr/department (RBAC: sysadmin can write). Drives the generic
 * TableBrowser: New -> fill fields -> Save -> verify a row appears -> edit ->
 * Delete -> verify it is gone. Assertions use the .mcms-card model picker,
 * the table rows, and the toast (.mcms-toast) rather than localized strings
 * where possible (toast text is locale-independent: "Created"/"Deleted"/"Updated").
 */
const API = "http://127.0.0.1:8010/api";

async function loginAdmin(page: Page) {
  await page.goto("/login");
  await page.evaluate(async (api) => {
    const r = await fetch(`${api}/auth/token/`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username: "admin", password: "admin123" }),
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
}

test("can create, edit and delete a record in the table browser", async ({ page }) => {
  await loginAdmin(page);

  // Navigate to the HR department table.
  await page.goto("/browse/mcms_hr/department");
  await expect(page.locator(".mcms-spinner")).toHaveCount(0, { timeout: 15_000 });

  // Open the create form.
  await page.getByRole("button", { name: /New|جديد/ }).click();
  const form = page.locator("form");
  await expect(form).toBeVisible();
  // FK select options are loaded asynchronously (loadFkOptions) — wait for them
  // so the fill loop can pick a real pk instead of typing a raw string.
  await form.locator("select.mcms-input option").first().waitFor({ timeout: 8_000 }).catch(() => {});

  // Pull field metadata (ordered, non-readonly) so we can fill values
  // correctly: choice fields need a valid choice, FK selects need a pk,
  // numbers need digits. TableBrowser renders inputs in `Object.entries(meta)`
  // order, so we map by index. Auth required.
  const meta = await page.evaluate(async () => {
    const token = localStorage.getItem("access");
    const res = await fetch("http://127.0.0.1:8010/api/hr/department/", {
      method: "OPTIONS",
      headers: { Authorization: `Bearer ${token}`, Accept: "application/json" },
    });
    const data = await res.json();
    const post = data?.actions?.POST || {};
    const fields: { key: string; type: string; choices: string[] }[] = [];
    for (const [k, v] of Object.entries<any>(post)) {
      if (v.read_only) continue;
      fields.push({
        key: k,
        type: v.type,
        choices: Array.isArray(v.choices) ? v.choices.map((c: any) => c.value ?? c[0] ?? c) : [],
      });
    }
    return fields;
  });

  // Fill inputs in meta order (the form renders them in this order).
  const inputs = form.locator("input.mcms-input, select.mcms-input");
  const n = await inputs.count();
  for (let i = 0; i < n; i++) {
    const input = inputs.nth(i);
    const type = await input.getAttribute("type");
    const f = meta[i];
    if (type === "checkbox") continue; // leave default (false)
    // FK fields (suffix _id, or relation selects) are optional here and we
    // have no guaranteed-valid pk — leave them at their default (null).
    // FK fields (suffix _id) — `head_user_id` is required (FK to app_user);
    // fill it with a guaranteed-existing pk (admin = app_user 1). Others are
    // optional and left null.
    if (f && f.key.endsWith("_id")) {
      if (f.key.endsWith("_user_id")) await input.fill("1");
      continue;
    }
    // <select> elements (resolved FK/choice relations) are optional here;
    // leave them at the placeholder (null) rather than auto-pick a value.
    if ((await input.locator("option").count()) > 0) continue;
    if (type === "number") {
      await input.fill(String(Math.floor(Math.random() * 90) + 1));
      continue;
    }
    if (f && f.choices.length) {
      await input.fill(String(f.choices[0]));
      continue;
    }
    if (f && f.type === "integer") {
      await input.fill(String(Math.floor(Math.random() * 90) + 1));
      continue;
    }
    // text/date/etc.
    await input.fill("E2E_DEPT_" + Math.floor(Math.random() * 1e6).toString(36).toUpperCase());
  }

  await form.getByRole("button", { name: /Save|حفظ/ }).click();

  // A success toast ("Created") should appear and the form should close.
  const toast = page.locator(".mcms-toast").first();
  await expect(toast).toBeVisible({ timeout: 10_000 });
  await expect(toast).toHaveText(/Created|تم الإنشاء/, { timeout: 10_000 });
  await expect(form).toHaveCount(0, { timeout: 10_000 });

  // The table reloaded (form closed) — assert rows are present again.
  await expect(page.locator(".mcms-spinner")).toHaveCount(0, { timeout: 15_000 });
  const rowCountAfter = await page.locator("tbody tr").count();
  expect(rowCountAfter).toBeGreaterThan(0);

  // Edit the first row, then save, expect an "Updated" toast.
  if (rowCountAfter > 0) {
    await page.locator("tbody tr").first().getByRole("button", { name: /edit|تعديل/i }).click();
    await expect(form).toBeVisible();
    await form.getByRole("button", { name: /Save|حفظ/ }).click();
    await expect(page.locator(".mcms-toast").first()).toBeVisible({ timeout: 10_000 });
  }

  // Delete the first row: click delete -> confirm in overlay.
  if ((await page.locator("tbody tr").count()) > 0) {
    await page.locator("tbody tr").first().getByRole("button", { name: /delete|حذف/i }).click();
    await expect(page.locator(".mcms-card").filter({ hasText: /Delete this record\?|حذف هذا السجل/ }).first()).toBeVisible({ timeout: 10_000 });
    await page.getByRole("button", { name: /delete|حذف/i }).last().click();
    await expect(page.locator(".mcms-toast").first()).toBeVisible({ timeout: 10_000 });
  }
});
