{
  inputs,
  app,

  lib,
  ...
}:
{

  imports = [
    inputs.nimi.nixosModules.default
  ];

  nimi = lib.mapAttrs (serviceName: service: {
    settings.binName = "${serviceName}-service";
    services.${serviceName} = {
      imports = [
        service.result
        {
          options.nimi = lib.mkOption {
            type = with lib.types; deferredModule;
            default = { };
            description = ''
              Let the modular service know that it's evaluated for nimi,
              by testing `options ? nimi`.
            '';
          };
        }
      ];
    };
  }) app.services.components;

  environment.variables = lib.concatMapAttrs (_: value: value.environment) app.services.components;
}
