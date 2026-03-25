{ inputs, flake-parts-lib, ... }:

{
  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      forgeModules = [
        ./modules/apps
        ./modules/packages.nix
      ];

      evalForgeModules =
        modules:
        lib.evalModules {
          modules = modules;
          specialArgs = { inherit flake-parts-lib inputs; };
        };

      forgeOptionsDoc =
        modules:
        pkgs.nixosOptionsDoc {
          warningsAreErrors = false;
          options = lib.removeAttrs (evalForgeModules modules).options [ "_module" ];
          transformOptions =
            opt:
            opt
            // {
              name = lib.removePrefix "perSystem.forge." opt.name;
              declarations = [ ];
              visible = lib.match ("^perSystem\\.forge\\.(apps|packages)(\\..+)?") opt.name != null;
            };
        };

      forgeOptions = forgeOptionsDoc forgeModules;
    in
    {
      packages = {
        _forge-config = pkgs.writeTextFile {
          name = "forge-config.json";
          text = builtins.toJSON config.forge;
        };

        _forge-options = pkgs.runCommand "options.json" { } ''
          cp ${forgeOptions.optionsJSON}/share/doc/nixos/options.json $out
        '';

        _forge-ui = pkgs.callPackage ../ui/package.nix {
          inherit (config.packages) _forge-config _forge-options;
          buildElmApplication = (inputs.elm2nix.lib.elm2nix pkgs).buildElmApplication;
        };
      };
    };
}
