{ inputs, flake-parts-lib, ... }@flakeArgs:

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
        {
          options = lib.concatMapAttrs (
            class: classModules:
            lib.optionalAttrs (classModules ? default) {
              ${class} = lib.mkOption {
                default = { };
                description = "Attrset to define ${class}.";
                type = lib.types.attrsOf (lib.types.submodule classModules.default);
              };
            }
          ) flakeArgs.config.flake.modules;
        }
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
        };

      forgeApps = lib.mapAttrs (_: x: x.config) config.evals.apps;
      forgeOptions = forgeOptionsDoc forgeModules;

      # Collect app icons into a derivation
      appIcons = pkgs.runCommand "app-icons" { } ''
        mkdir -p $out
        ${lib.concatStringsSep "\n" (
          lib.attrValues (
            lib.mapAttrs (appName: app: ''
              mkdir -p $out/${appName}
              ${if app.icon or null != null then "cp ${app.icon} $out/${appName}/icon.svg" else ""}
            '') forgeApps
          )
        )}
      '';
    in
    {
      packages = {
        _forge-config = pkgs.writeTextFile {
          name = "forge-config.json";
          # FixMe(performance): this currently requires a lot of compiling
          # due to `pkgs` being used in things like `pythonAppBuilder.packages.build`.
          text = builtins.toJSON (
            config.forge
            // lib.concatMapAttrs (
              class: classModules:
              lib.optionalAttrs (classModules ? default) {
                ${class} = lib.mapAttrs (_: x: x.config) config.evals.${class};
              }
            ) flakeArgs.config.flake.modules
          );
        };

        _forge-options = pkgs.runCommand "options.json" { } ''
          cp ${forgeOptions.optionsJSON}/share/doc/nixos/options.json $out
        '';

        _forge-ui = pkgs.callPackage ../ui/package.nix {
          inherit (config.packages) _forge-config _forge-docs _forge-options;
          inherit appIcons;
          buildElmApplication = (inputs.elm2nix.lib.elm2nix pkgs).buildElmApplication;
        };

        _forge-docs = pkgs.callPackage ../flake/packages/forge-docs.nix { };

        _forge-announcement = pkgs.writeShellApplication {
          name = "announce-projects";
          passthru = import ../maintainers/mk-announcement.nix { inherit forgeApps pkgs lib; };
          text = ''
            cat <<EOF
            To generate project announcement, use:

            \`\`\`
            nix run .#_forge-announcement.<APP_NAME>
            \`\`\`

            Available apps:
            ${lib.concatMapStringsSep "\n" (app: "- " + app.name) (lib.attrValues forgeApps)}
            EOF
          '';
        };
      };
    };
}
