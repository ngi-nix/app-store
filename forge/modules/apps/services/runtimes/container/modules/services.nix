{
  app,

  lib,
  ...
}:
lib.mapAttrs (serviceName: service: {
  imports = [
    service.result
    {
      options.nimi = lib.mkOption {
        type = with lib.types; lazyAttrsOf (attrsOf anything);
        default = { };
        description = ''
          Let the modular service know that it's evaluated for nimi,
          by testing `options ? nimi`.
        '';
      };
    }
  ];
}) app.services.components
