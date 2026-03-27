{
  config,
  lib,

  inputs,
  nimi,
  pkgs,
  system,
  ...
}:
{
  options = {
    # General configuration
    name = lib.mkOption {
      type = lib.types.str;
      default = "my-application";
    };
    description = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    usage = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Application usage description in markdown format.";
    };
    links = lib.mkOption {
      type = lib.types.submodule ./links.nix;
      default = { };
      description = "Links related to this project";
    };
    ngi = lib.mkOption {
      type = lib.types.submodule ./ngi;
      default = { };
      description = "NGI-specific options.";
    };

    # Portable services configuration
    # https://nixos.org/manual/nixos/unstable/#modular-services
    services = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submoduleWith {
          specialArgs = { inherit pkgs inputs; };
          modules = [ ./services ];
        }
      );
      default = { };
      description = "Portable services.";
      # map user-config to a format which can be used by modular services
      apply =
        self:
        lib.mapAttrs (
          _: service:
          service
          // {
            result = {
              process.argv =
                let
                  command = if lib.isDerivation service.command then lib.getExe service.command else service.command;
                in
                [ command ] ++ service.argv;
              configData = service.configData;
            };
          }
        ) self;
    };

    # Programs shell configuration
    programs = lib.mkOption {
      type = lib.types.submodule ./programs;
      default = { };
      description = "Programs shell configuration.";
    };

    # Container configuration
    container = lib.mkOption {
      type = lib.types.submodule {
        imports = [ ./container ];
        _module.args.app = config;
        _module.args.pkgs = pkgs;
        _module.args.nimi = nimi;
      };
      default = { };
      description = "Container configuration.";
    };

    # NixOS/VM configuration
    nixos = lib.mkOption {
      type = lib.types.submodule {
        imports = [ ./nixos ];
        _module.args.app = config;
        _module.args.inputs = inputs;
        _module.args.system = system;
      };
      default = { };
      description = "NixOS system configuration.";
    };

    # Test configuration
    test = {
      script = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = ''
          Bash script to run application tests inside a NixOS machine.

          The application's services are available in the machine.
          Run with: nix build .#<app>.test
        '';
        example = lib.literalExpression ''
          '''
          curl -f http://localhost:5000/users
          '''
        '';
      };
    };
  };
}
