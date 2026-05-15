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
          lib.mkIf package.config.build.goPackageBuilder.enable (
            pkgs.buildGoModule (
              finalAttrs:
              {
                inherit (package.config) pname version;
                inherit (package.config.build.goPackageBuilder)
                  vendorHash
                  modRoot
                  subPackages
                  ldflags
                  tags
                  proxyVendor
                  ;
                src = sharedBuildAttrs.pkgSource package.config;
                patches = package.config.source.patches;
                nativeBuildInputs = package.config.build.goPackageBuilder.packages.build;
                buildInputs = package.config.build.goPackageBuilder.packages.run;
                nativeCheckInputs = package.config.build.goPackageBuilder.packages.check;
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
