{
  lib,
  flake-parts-lib,
  ...
}:

{
  options = {
    perSystem = flake-parts-lib.mkPerSystemOption (
      {
        pkgs,
        sharedBuildAttrs,
        ...
      }@systemArgs:
      {
        packages = lib.mapAttrs (
          packageName: package:
          # Note that `packages` is a `lazyAttrsOf`,
          # hence `lib.mkIf false` does not remove the attribute key.
          # This does not matter because at least one builder has to be enabled,
          # hence the value always has a definition.
          lib.mkIf package.config.build.standardBuilder.enable (
            package.config.build.standardBuilder.stdenv.mkDerivation (
              finalAttrs:
              {
                inherit (package.config) pname version;
                src = sharedBuildAttrs.pkgSource package.config;
                patches = package.config.source.patches;
                nativeBuildInputs = package.config.build.standardBuilder.packages.build;
                buildInputs = package.config.build.standardBuilder.packages.run;
                nativeCheckInputs = package.config.build.standardBuilder.packages.check;
                passthru = sharedBuildAttrs.pkgPassthru package.config finalAttrs.finalPackage;
                meta = sharedBuildAttrs.pkgMeta package.config;
              }
              // package.config.build.extraAttrs
              // lib.optionalAttrs package.config.build.debug sharedBuildAttrs.debugShellHookAttr
            )
          )
        ) systemArgs.config.evals.packages;
      }
    );
  };
}
