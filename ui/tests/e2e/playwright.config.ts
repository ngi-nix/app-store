import { defineConfig, devices } from "@playwright/test";
import process from "node:process";

export default defineConfig({
  outputDir: "test-results",
  reporter: [["html", { open: "never", outputFolder: "playwright-report" }]],
  use: {
    // NOTE: https://github.com/microsoft/playwright/issues/22592#issuecomment-1519991484
    // BASE_URL should end with "/"
    // every test should us relative paths prepended with "./"
    baseURL: process.env.BASE_URL || "http://localhost:3000",
    trace: "retain-on-failure",
    video: "retain-on-failure",
    colorScheme: "dark", // assume dark by default
  },
  webServer: {
    command: "dev-ui",
    url: "http://localhost:3000",
    reuseExistingServer: !process.env.CI,
    stdout: "pipe",
    stderr: "pipe",
  },
  // Give failing tests 3 retry attempts
  retries: 3,
  projects: [
    {
      name: "chromium",
      use: {
        ...devices["Desktop Chrome"],
      },
    },
    {
      name: "firefox",
      use: {
        ...devices["Desktop Firefox"],
      },
    },
    {
      name: "webkit",
      use: {
        ...devices["Desktop Safari"],
      },
    },
    {
      name: "mobile",
      use: {
        ...devices["Pixel 7"],
      },
    },
  ],
});
