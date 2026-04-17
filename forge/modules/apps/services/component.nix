{
  inputs,
  pkgs,

  lib,
  ...
}:
{
  imports = [
    (lib.modules.importApply (inputs.nixpkgs + "/lib/services/config-data.nix") { inherit pkgs; })
  ];

  options = {
    command = lib.mkOption {
      type = lib.types.either lib.types.package lib.types.str;
      description = "Main command to use for the service.";
    };

    argv = lib.mkOption {
      type = lib.types.listOf lib.types.singleLineStr;
      default = [ ];
      description = "List of arguments that will be passed to the main program.";
    };

    # NOTE: this is a list so we're consistent with the container's `imageConfig.Env`
    environment = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Environment variables.";
    };
  };
}
