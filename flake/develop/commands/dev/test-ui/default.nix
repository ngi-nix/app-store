{
  lib,
  playwright-test,
  writeShellScriptBin,
  ...
}:
let
  script = writeShellScriptBin "test-ui" ''
    ${lib.getExe playwright-test} test -c ui/tests/e2e "$@"
  '';
in
script.overrideAttrs (_: {
  meta.description = "UI playwright test script";
})
