{
  configRoot,
  config,
  lib,
  pkgs,
  ...
}:

{
  description = "Python bindings for IronCalc";

  inherit (configRoot.forge.packages.ironcalc)
    homePage
    license
    source
    version
    ;

  build.pythonPackageBuilder = {
    enable = true;
    packages = {
      build = [
        pkgs.pkg-config
        pkgs.rustPlatform.cargoSetupHook
        pkgs.rustPlatform.maturinBuildHook
      ];
      run = [
        pkgs.bzip2
        pkgs.zstd
      ];
      check = [
        pkgs.python3Packages.pytestCheckHook
      ];
    };
    importsCheck = [ "ironcalc" ];
  };

  build.extraAttrs = {
    postPatch = ''
      cd bindings/python
    '';

    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      inherit (configRoot.packages.ironcalc) src;
      hash = configRoot.packages.ironcalc-tools.cargoHash;
    };

    cargoRoot = "../..";
  };
}
