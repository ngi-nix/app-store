{
  config,
  pkgs,
  lib,
  ...
}:

{
  services = {
    runtimes = {
      container = {
        enable = true;
        imageConfig.CMD = lib.mkForce [
          "hola"
        ];
      };

      nixos = {
        enable = lib.mkForce false;
      };
    };
  };
}
