{
  flake-parts-lib,
  lib,
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
          lib.mkIf package.config.build.npmPackageBuilder.enable (
            pkgs.buildNpmPackage (
              finalAttrs:
              {
                inherit (package.config) pname version;
                inherit (package.config.build.npmPackageBuilder)
                  npmDepsHash
                  npmInstallFlags
                  ;
                src = sharedBuildAttrs.pkgSource package.config;
                patches = package.config.source.patches or [ ];
                nativeBuildInputs = [ pkgs.nodejs ] ++ package.config.build.npmPackageBuilder.packages.build;
                buildInputs = package.config.build.npmPackageBuilder.packages.run;
                nativeCheckInputs = package.config.build.npmPackageBuilder.packages.check;
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
