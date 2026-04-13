import { expect, test } from "@playwright/test";

test.describe("Permalinks and Smooth Scrolling", () => {
  const targetPage = "./app/python-web";

  test("direct navigation to a hash anchor scrolls to the element", async ({ page }) => {
    await page.goto(`${targetPage}#resources`);

    const grantsSection = page.locator("#resources");

    await expect(grantsSection).toBeInViewport();
  });
});
