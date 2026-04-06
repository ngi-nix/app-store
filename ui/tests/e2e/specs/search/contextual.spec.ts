import { expect, test } from "@playwright/test";

test("search works in homepage and updates URL", async ({ page }) => {
  await page.goto("./");

  const searchBar = page.getByTestId("main-search-bar");
  await searchBar.fill("python-web");

  const results = page.getByTestId("app-result");
  await expect(results).toHaveCount(1);

  await expect(page).toHaveURL(/.*[?&]q=python-web/);
});

test("homepage loads search results directly from query param", async ({ page }) => {
  await page.goto("./apps?q=python-web");

  const searchBar = page.getByTestId("main-search-bar");
  await expect(searchBar).toHaveValue("python-web");

  const results = page.getByTestId("app-result");
  await expect(results).toHaveCount(1);
});

test("search works in options page and updates URL", async ({ page }) => {
  const responsePromise = page.waitForResponse((response) => response.url().includes("forge-options.json"));
  await page.goto("./recipe/options");
  await responsePromise;

  await expect(page.getByTestId("option-result").first()).toBeVisible();

  const searchTerm = "apps.*.description";
  const searchBar = page.getByTestId("main-search-bar");
  await searchBar.fill(searchTerm);

  const results = page.getByTestId("option-result");
  await expect(results).toHaveCount(1);

  const expectedParam = encodeURIComponent(searchTerm);
  await expect(page).toHaveURL(
    new RegExp(`.*[?&]q=${expectedParam.replace(/\*/g, "\\*")}`),
  );
});

test("options page loads search results directly from query param", async ({ page }) => {
  const searchTerm = "apps.*.description";
  const responsePromise = page.waitForResponse((response) => response.url().includes("forge-options.json"));

  await page.goto(`./recipe/options?q=${encodeURIComponent(searchTerm)}`);
  await responsePromise;

  const searchBar = page.getByTestId("main-search-bar");
  await expect(searchBar).toHaveValue(searchTerm);

  const results = page.getByTestId("option-result");
  await expect(results).toHaveCount(1);
});
