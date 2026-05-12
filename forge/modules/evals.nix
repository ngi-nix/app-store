# The recipe flow is:
# 1. `flakeConfig.flake.modules.{apps,packages,nixos}`
# 2. - `flakeConfig.allSystems.${system}.evals.{apps,packages}`
#    - `nixosConfigurations`
# 3. - `{apps,packages}.${system}`
#    - `nixosModules`
{
  inputs,
  lib,
  flake-parts-lib,
  specialArgs,
  ...
}@flakeArgs:
{

  config = {
    # flake.modules :: lazyAttrsOf (lazyAttrsOf deferredModule)
    #
    # Each `flake.modules.${class}.${name}` is a module fixpoint
    # (ie. has it's own `config`/`options`)
    # of a given type (`class`), except for `generic`.
    flake.modules.generic = { };
  };

  options = {
    # `perSystem` uses a deprecated `deferredModule` type
    # predating `lib.types.deferredModule`,
    # hence the use of `mkPerSystemOption`
    # But being a `deferredModule` this can perfectly define a `config` too.
    perSystem = flake-parts-lib.mkPerSystemOption (
      {
        system,
        pkgs,
        ...
      }@systemArgs:
      {
        options = {
          # Gather the `lib.evalModules` of modules in `flake.modules`
          evals = lib.mapAttrs (
            class: _modules:
            lib.mkOption {
              type = lib.types.attrsOf lib.types.anything;
              internal = true;
            }
          ) flakeArgs.config.flake.modules;
        };
        config = {
          evals = lib.mapAttrs (
            class: modules:
            lib.mapAttrs (
              name: module:
              (lib.evalModules {
                inherit class;
                specialArgs = specialArgs // {
                  inherit system name;
                  # `nixpkgs-pkgs` is to be used
                  # when it's necessary to avoid an infinite recursion
                  # between the extend `pkgs` below and `systemArgs.config.packages`
                  # This happens when using `pkgs` inside a the `default` of an option,
                  # or as a direct value of `build.extraAttrs`.
                  nixpkgs-pkgs = pkgs;
                  pkgs = pkgs.extend (final: prev: systemArgs.config.packages);
                  packages = lib.mapAttrs (_: p: p.config) systemArgs.config.evals.packages;
                };
                modules = [
                  modules.default
                  module
                ];
              })
            ) (lib.removeAttrs flakeArgs.config.flake.modules.${class} [ "default" ])
          ) flakeArgs.config.flake.modules;
        };
      }
    );
  };

}
