import { expect, test } from "@playwright/test";

test("deployment reachable and Elm app mounts", async ({ page }) => {
  await page.goto("./");

  await expect(page).toHaveTitle(/NGI Forge/i);
});
