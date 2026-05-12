{
  flake-parts-lib,
  lib,
  ...
}:

{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    {
      pkgs,
      sharedBuildAttrs,
      ...
    }@systemArgs:
    {
      packages = lib.mapAttrs (
        packageName: package:
        lib.mkIf package.config.build.rustPackageBuilder.enable (
          pkgs.rustPlatform.buildRustPackage (
            finalAttrs:
            {
              inherit (package.config) pname version;
              inherit (package.config.build.rustPackageBuilder)
                cargoHash
                cargoBuildFlags
                ;

              src = sharedBuildAttrs.pkgSource package.config;
              patches = package.config.source.patches or [ ];

              nativeBuildInputs = package.config.build.rustPackageBuilder.packages.build;
              buildInputs = package.config.build.rustPackageBuilder.packages.run;
              nativeCheckInputs = package.config.build.rustPackageBuilder.packages.check;

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
}
