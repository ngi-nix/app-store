{
  lib,
  ...
}:
{
  options = {
    grants = lib.mkOption {
      type = lib.types.submodule ./grants.nix;
      default = { };
      description = "NGI grants supporting this project.";
    };
  };
}
