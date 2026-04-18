{
  lib,
  gitMinimal,
  gnutar,
  python3,
  writers,
  writeShellApplication,
}:
let
  devUIDir = builtins.toString ../dev-ui;
  script = writers.writePython3Bin "mock-forge-config.py" {
    libraries = [ python3.pkgs.faker ];
    flakeIgnore = [
      "E402"
      "E501"
    ];
  } (builtins.replaceStrings [ "@devUIDir@" ] [ devUIDir ] (builtins.readFile ./generate.py));
in
writeShellApplication {
  name = "mock-forge-config";
  runtimeInputs = [
    gnutar
    gitMinimal
  ];
  text = ''
    ${lib.getExe script} "$@"
  '';
  meta.description = "Helper script for UI tests to generate mock backend recipes";
}
