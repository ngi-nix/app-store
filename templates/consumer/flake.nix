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
    import-tree.follows = "ngi-forge/import-tree";
    nimi.follows = "ngi-forge/nimi";
    elm2nix.follows = "ngi-forge/elm2nix";
    flake-parts.follows = "ngi-forge/flake-parts";
    nix-utils.follows = "ngi-forge/nix-utils";
    nixpkgs.follows = "ngi-forge/nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ngi-forge, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        ngi-forge.flakeModules.default
        (inputs.import-tree ./recipes)
      ];

      debug = true;

      perSystem =
        { system, pkgs, ... }:
        {
          # load packages and applications from other forges
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              (final: prev: {
                # WARN:
                # make sure this is unique for each provider forge you use,
                # else you may face issues
                forgePkgs = ngi-forge.packages.${system};
              })
            ];
          };

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
