{
  config,
  pkgs,
  lib,
  ...
}:

pkgs.mypkgs.hello-app.extend {
  container = {
    imageConfig.CMD = lib.mkForce [
      "hola"
    ];
  };

  nixos = {
    enable = lib.mkForce false;
  };
}
