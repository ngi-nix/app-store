# How to test

## How to test the UI

```
playwright test -c ui/tests/e2e
playwright test -c ui/tests/e2e --project=chromium
playwright test -c ui/tests/e2e --project=mobile
```

```
playwright test -c ui/tests/e2e --ui
playwright test -c ui/tests/e2e --ui-host 127.0.0.1
```

```
env BASE_URL="https://ngi-nix.github.io/forge/" playwright test -c ui/tests/e2e --ui-host 127.0.0.1
```
