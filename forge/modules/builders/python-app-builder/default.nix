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
        lib.mkIf package.config.build.pythonAppBuilder.enable (
          pkgs.python3Packages.buildPythonApplication (
            finalAttrs:
            {
              inherit (package.config) pname version;
              inherit (package.config.build.pythonAppBuilder.packages)
                build-system
                dependencies
                optional-dependencies
                ;
              inherit (package.config.build.pythonAppBuilder)
                disabledTests
                ;
              format = "pyproject";
              src = sharedBuildAttrs.pkgSource package.config;
              patches = package.config.source.patches;
              nativeBuildInputs = package.config.build.pythonAppBuilder.packages.build;
              buildInputs = package.config.build.pythonAppBuilder.packages.run;
              nativeCheckInputs = package.config.build.pythonAppBuilder.packages.check;
              # Warning(usability): users may want to disable tests in one setting, ie. without erasing them.
              doCheck = package.config.build.pythonAppBuilder.packages.check != [ ];
              # Warning(consistency): such renames are not done elsewhere,
              # eg. in `packages.${package}.build.npmPackageBuilder.npmDepsHash`
              pythonImportsCheck = package.config.build.pythonAppBuilder.importsCheck;
              pythonRelaxDeps = package.config.build.pythonAppBuilder.relaxDeps;
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
