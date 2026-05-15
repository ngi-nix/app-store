{
  description = "NGI Forge";

  nixConfig = {
    extra-substituters = [ "https://ngi-forge.cachix.org" ];
    extra-trusted-public-keys = [
      "ngi-forge.cachix.org-1:PK0qK+LhWt4GQVpUtPapyXWxJSM1GhtmPW6CRCoygz0="
    ];
  };

  inputs = {
    ngi-forge.url = "github:ngi-nix/forge";
    elm2nix.follows = "ngi-forge/elm2nix";
    import-tree.follows = "ngi-forge/import-tree";
    flake-parts.follows = "ngi-forge/flake-parts";
    nixpkgs.follows = "ngi-forge/nixpkgs";
    nix-utils.follows = "ngi-forge/nix-utils";
  };

  outputs =
    inputs@{ flake-parts, ngi-forge, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        ngi-forge.flakeModules.base
        (inputs.import-tree ./recipes)
      ];

      perSystem =
        { system, ... }:
        {
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
