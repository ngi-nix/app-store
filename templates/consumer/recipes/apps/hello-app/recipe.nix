{
  config,
  pkgs,
  lib,
  ...
}:

{
  container = {
    imageConfig.CMD = lib.mkForce [
      "hola"
    ];
  };

  nixos = {
    enable = lib.mkForce false;
  };
}
