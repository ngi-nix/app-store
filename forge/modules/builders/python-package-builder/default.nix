{
  lib,
  flake-parts-lib,
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
        lib.mkIf package.config.build.pythonPackageBuilder.enable (
          pkgs.python3Packages.buildPythonPackage (
            finalAttrs:
            {
              inherit (package.config) pname version;
              inherit (package.config.build.pythonPackageBuilder.packages)
                build-system
                dependencies
                optional-dependencies
                ;
              inherit (package.config.build.pythonPackageBuilder)
                disabledTests
                ;
              format = "pyproject";
              src = sharedBuildAttrs.pkgSource package.config;
              patches = package.config.source.patches;
              nativeBuildInputs = package.config.build.pythonPackageBuilder.packages.build;
              buildInputs = package.config.build.pythonPackageBuilder.packages.run;
              nativeCheckInputs = package.config.build.pythonPackageBuilder.packages.check;
              # Warning(usability): users may want to disable tests in one setting, ie. without erasing them.
              doCheck = package.config.build.pythonPackageBuilder.packages.check != [ ];
              pythonImportsCheck = package.config.build.pythonPackageBuilder.importsCheck;
              pythonRelaxDeps = package.config.build.pythonPackageBuilder.relaxDeps;
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
