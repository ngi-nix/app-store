import { expect, test } from "@playwright/test";
import { TEST_APP_SEARCH } from "./constants";

test.describe("Home Page", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("./");
  });

  test("deployment reachable and Elm app mounts", async ({ page }) => {
    await expect(page).toHaveTitle(/NGI Forge/i);
  });

  test("shows list of apps", async ({ page }) => {
    const apps = page.getByTestId("app-result");
    await expect(await apps.count()).toBeGreaterThan(0);
  });

  test("search filters apps", async ({ page }) => {
    const searchBar = page.getByTestId("main-search-bar");
    await expect(searchBar).toBeVisible();

    await searchBar.fill(TEST_APP_SEARCH);

    const apps = page.getByTestId("app-result");
    await expect(await apps.count()).toBeGreaterThan(0);
  });

  test("clicking an app navigates to app details", async ({ page }) => {
    const firstApp = page.getByTestId("app-result").first();
    const href = await firstApp.getAttribute("href");
    expect(href).not.toBeNull();

    await firstApp.click();
    await expect(page).toHaveURL(new RegExp(`${href?.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}$`));
  });
});
