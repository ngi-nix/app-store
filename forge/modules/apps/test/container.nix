{
  lib,

  app,
  config,
  pkgs,
  ...
}:
{
  options = {
    result.containerBuild = lib.mkOption {
      internal = true;
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "NixOS test derivation for the container runtime.";
    };
  };

  config = {
    result.containerBuild = lib.mkIf app.services.runtimes.container.enable (
      let
        containerRuntime = app.services.runtimes.container;
      in
      (pkgs.testers.runNixOSTest {
        name = "${app.name}-container-test";
        nodes.machine = {
          virtualisation.podman.enable = true;
          virtualisation.containers.enable = true;
          virtualisation.diskSize = 4096;
          system.stateVersion = "25.11";
          environment.systemPackages = app.programs.packages ++ config.packages ++ [ pkgs.podman-compose ];
        };
        testScript =
          if containerRuntime.composeFile != null then
            ''
              machine.start()
              machine.wait_for_unit("multi-user.target")
              machine.succeed("${containerRuntime.result.build}/bin/build-oci-image")
              machine.succeed("podman load < ${app.name}.tar")
              machine.succeed(
                "podman-compose --profile services --file ${containerRuntime.result.build}/compose.yaml up -d"
              )
              machine.succeed("${pkgs.writeShellScript "${app.name}-container-test-script" config.script}")
            ''
          else
            ''
              machine.start()
              machine.wait_for_unit("multi-user.target")
              machine.succeed("${containerRuntime.result.build}/bin/build-oci-image")
              machine.succeed("podman load < ${app.name}.tar")
              machine.succeed(
                "podman run -d --name ${app.name} --network=host localhost/${app.name}:${containerRuntime.tag}"
              )
              machine.succeed("${pkgs.writeShellScript "${app.name}-container-test-script" config.script}")
            '';
      }).overrideTestDerivation
        (_: lib.optionalAttrs (!config.sandbox) { __noChroot = true; })
    );
  };
}
