{ inputs, ... }:
{
  perSystem =
    {
      self',
      pkgs,
      lib,
      ...
    }:

    let
      formatter = pkgs.callPackage ./formatter.nix { inherit inputs; };
      devShell = pkgs.callPackage ./devshell.nix { inherit inputs formatter; };

      devPkgs = with pkgs; [
        dive
        elmPackages.elm
        elmPackages.elm-language-server
        elmPackages.elm-review
        elmPackages.elm-test
        elmPackages.elm-test-rs
        esbuild
        json-diff
        nixfmt
        nodejs
        playwright-test
        podman-compose
        python3
        self'.packages.elm-watch
        self'.packages.elm2nix
        systemd-manager-tui
        watchman
      ];
    in

    {
      formatter = formatter.package;

      devShells.default =
        (devShell.extend (
          final: prev: {
            packages = prev.packages ++ devPkgs;
          }
        )).finalPackage;
    };
}
