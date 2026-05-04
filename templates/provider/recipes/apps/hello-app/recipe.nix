{
  configRoot,
  config,
  lib,
  pkgs,
  ...
}:

{
  name = "hello-app";
  description = "Say hello to Nix.";

  programs = {
    packages = [
      configRoot.packages.hello-nix
    ];

    runtimes.shell = {
      enable = true;
    };
  };
}
