{
  description = "Nix Forge";

  nixConfig = {
    extra-substituters = [ "https://ngi-forge.cachix.org" ];
    extra-trusted-public-keys = [
      "ngi-forge.cachix.org-1:PK0qK+LhWt4GQVpUtPapyXWxJSM1GhtmPW6CRCoygz0="
    ];
  };

  inputs = {
    nixpkgs.follows = "nix-forge/nixpkgs";
    flake-parts.follows = "nix-forge/flake-parts";
    nix-forge.url = "github:ngi-nix/forge";
    elm2nix.follows = "nix-forge/elm2nix";
    nix-utils.follows = "nix-forge/nix-utils";
    nimi.follows = "nix-forge/nimi";
  };

  outputs =
    inputs@{ flake-parts, nix-forge, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [ nix-forge.flakeModules.default ];

      debug = true;

      perSystem =
        { system, lib, ... }:
        {
          _module.args.nimi = inputs.nimi.packages.${system}.nimi;

          # forge.apps = lib.attrValues (
          #   lib.filterAttrs (name: value: lib.hasSuffix "-app" name) inputs.nix-forge.packages.${system}
          # );

          forge = {
            repositoryUrl = "github:me/my-forge";
            recipeDirs = {
              packages = "recipes/packages";
              apps = "recipes/apps";
            };
          };
        };
    };
}
