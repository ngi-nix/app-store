{
  config,
  pkgs,
  lib,
  ...
}:

{
  name = "qlever-ui-app";
  displayName = "QLever UI";
  description = "Web-based user interface for QLever SPARQL engine.";
  usage = ''
    First, download a [test dataset](https://docs.qlever.dev/use-cases), like the Olympics one:

    ```shellSession
    $ qlever setup-config olympics --system native
    $ qlever get-data

    $ qlever index
    ```

    After the indexing is finished, open the UI in your browser: `http://localhost:8000`.

    Then, execute the following query:

    ```sqlite
    SELECT * WHERE { ?s ?p ?o } LIMIT 10
    ```

    If everything works, the query results should show up under the input field.

    _Available in: container, nixos._
  '';

  links = {
    website = "https://github.com/qlever-dev/qlever-ui";
    source = "https://github.com/qlever-dev/qlever-ui";
  };

  ngi.grants = {
    Review = [
      "QLever-similarity"
    ];
  };

  services = {
    components.qlever-ui = {
      command = pkgs.mypkgs.qlever-ui;
      argv = [
        "--bind=0.0.0.0:8000"
      ];
      environment = {
        DJANGO_SETTINGS_MODULE = "qlever.settings";
      };
    };

    runtimes = {
      container = {
        enable = true;
        packages = with pkgs; [
          bash
          coreutils
          mypkgs.qlever-ui
          rsync
          subversion
        ];
        imageConfig = {
          WorkingDir = "/app";
        };
        setup =
          # bash
          ''
            WORKDIR=$PWD

            # only copy db on first run so we don't overwrite it
            if [ ! -d "$WORKDIR/db" ]; then
              rsync -a --chmod=u=rwX,g=rwX,o=rX ${pkgs.mypkgs.qlever-ui}/opt/db "$WORKDIR"
            fi

            rsync -a --chmod=u=rwX,go=rX --exclude='/db/' ${pkgs.mypkgs.qlever-ui}/opt/ "$WORKDIR"

            qlever-ui-manage makemigrations --merge
            qlever-ui-manage migrate
          '';
      };

      nixos = {
        enable = true;
        setup = config.services.runtimes.container.setup;
        vm = {
          forwardPorts = [
            "8000:8000"
          ];
        };
        extraConfig = {
          systemd.services."qlever-ui-app-setup" = {
            path = with pkgs; [
              mypkgs.qlever-ui
              rsync
              subversion
            ];
            serviceConfig = {
              User = "qlever-ui";
              Group = "qlever-ui";
              DynamicUser = true;
              StateDirectory = [ "qlever" ];
              WorkingDirectory = "/var/lib/qlever";
            };
            environment.QLEVERUI_DATABASE_URL = "sqlite:////var/lib/qlever/db/qleverui.sqlite3";
          };

          systemd.services."qlever-ui" = {
            serviceConfig = {
              User = "qlever-ui";
              Group = "qlever-ui";
              DynamicUser = true;
              StateDirectory = [ "qlever" ];
              WorkingDirectory = "/var/lib/qlever";
            };
            environment.QLEVERUI_DATABASE_URL = "sqlite:////var/lib/qlever/db/qleverui.sqlite3";
            after = [ "qlever-ui-app-setup.service" ];
            requires = [ "qlever-ui-app-setup.service" ];
          };

          networking.firewall.allowedTCPPorts = [ 8000 ];
        };
      };
    };
  };

  test.script = ''
    curl="curl --retry 5 --retry-max-time 30 --retry-all-errors"

    $curl localhost:8000 | grep -i "qlever" || $curl localhost:8000
  '';
}
