import { expect, test } from "@playwright/test";

test("navigation menu responds to viewport size", async ({ page, isMobile }) => {
  await page.goto("./");

  const navToggler = page.getByTestId("navbar-toggler");
  const optionsLink = page.getByRole("link", { name: /options/i });

  if (isMobile) {
    await expect(navToggler).toBeVisible();
    await expect(optionsLink).not.toBeVisible();

    await navToggler.click();
    await expect(optionsLink).toBeVisible();
  } else {
    await expect(navToggler).not.toBeVisible();
    await expect(optionsLink).toBeVisible();
  }
});
