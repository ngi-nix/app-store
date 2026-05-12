{
  lib,
  inputs,
  flake-parts-lib,
  ...
}@flakeArgs:

{
  config = {
    # Expose `app.config.services.runtimes.nixos`
    # as `flake.modules.nixos."${system}:${appName}"`
    flake.modules.nixos = lib.concatMapAttrs (
      system: systemConfig:
      lib.concatMapAttrs (
        appName: app:
        lib.optionalAttrs app.config.services.runtimes.nixos.enable {
          ${appName} = lib.mkMerge (lib.attrValues app.config.services.runtimes.nixos.result.modules);
        }
      ) systemConfig.evals.apps
    ) flakeArgs.config.allSystems;
    flake.nixosModules = flakeArgs.config.flake.modules.nixos;
    # The evaluation goes to `nixosConfigurations."${system}:${appName}"`
    # Eg. `nix run .#nixosConfigurations."x86_64-linux:mox".config.system.build.vm`
    flake.nixosConfigurations = lib.concatMapAttrs (
      system: systemConfig:
      lib.concatMapAttrs (name: nixos: {
        "${system}:${name}" = inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ nixos ];
        };
      }) flakeArgs.config.flake.modules.nixos
    ) flakeArgs.config.allSystems;
  };

  options = {
    perSystem = flake-parts-lib.mkPerSystemOption (
      {
        pkgs,
        system,
        ...
      }@systemArgs:
      {
        config =
          let
            shellBundle =
              app:
              let
                appDrv = pkgs.symlinkJoin {
                  inherit (app) name;
                  paths = app.programs.packages;
                };
              in
              # Passthru
              appDrv.overrideAttrs (_: {
                passthru = appPassthru app appDrv;
              });

            mkPassthru =
              app:
              lib.fix (self: {
                config = app;

                extend =
                  module:
                  let
                    appExtended = app.result.extend module;
                  in
                  shellBundle appExtended;

                # This is meant to be used in consumer templates.
                #
                # The purpose of it is to only return a recipe module which
                # consumer forges can compose into proper applications.
                #
                # That's why we remove `result`, because it's tied to the
                # providers' already generated applications, which can cause
                # conflicts.
                extendRecipe =
                  module: lib.filterAttrsRecursive (name: _: name != "result") (self.extend module).config;
              })
              // lib.optionalAttrs app.programs.runtimes.program.enable {
                program = app.programs.mainPackage;
              }
              // lib.optionalAttrs app.services.runtimes.container.enable {
                container = app.services.runtimes.container.result.build;
              }
              // lib.optionalAttrs app.services.runtimes.nixos.enable {
                vm = app.services.runtimes.nixos.result.build;
                nixosModules.default = {
                  imports =
                    let
                      m = app.services.runtimes.nixos.result.modules;
                    in
                    [
                      m.setup
                      m.nimi
                      m.packages
                      m.extraConfig
                    ];
                };
                nixos = {
                  modules = app.services.runtimes.nixos.result.modules;
                  vm = app.services.runtimes.nixos.result.build;
                };
              }
              // lib.optionalAttrs app.programs.runtimes.program.enable {
                test-program =
                  assert
                    (app.programs.mainPackage != null)
                    || throw "${app.name} has runtimes.program.enable but programs.mainPackage is missing";
                  assert
                    (lib.hasAttrByPath [ "meta" "mainProgram" ] app.programs.mainPackage)
                    || throw "${app.name}'s programs.mainPackage is missing a meta.mainProgram attribute";
                  app.programs.mainPackage;
              }
              // lib.optionalAttrs (app.services.runtimes.container.enable && app.test.script != "") {
                test-container = app.test.result.containerBuild;
              }
              // lib.optionalAttrs (app.services.runtimes.nixos.enable && app.test.script != "") {
                test = app.test.result.build;
              };

            # finalApp parameter is currently not used in this function
            appPassthru = app: finalApp: mkPassthru app;

            allApps = lib.mapAttrs' (appName: app: {
              name = "${appName}-app";
              value = shellBundle app.config;
            }) systemArgs.config.evals.apps;
          in
          {
            # Expose apps as packages with "-app" suffix
            packages = allApps;
          };
      }
    );
  };
}
