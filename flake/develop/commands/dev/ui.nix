# Usage:
#   nix-shell --run 'dev-ui'
{
  lib,
  writeShellApplication,
}:
(writeShellApplication {
  name = "dev-ui";
  text = lib.readFile ./ui;
  meta.description = "UI dev script";
})
