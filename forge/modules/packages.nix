{
  lib,
  flake-parts-lib,
  ...
}:

{
  options.perSystem = flake-parts-lib.mkPerSystemOption (systemArgs: {
    # Config section is now provided by builder modules
    config =
      let
        # Process warnings: filter to get active warnings (condition = true), then show them
        activeWarnings = lib.filter (x: x.condition) systemArgs.config.warnings;
        showWarnings = lib.foldr (w: acc: lib.warn w.message acc) true activeWarnings;

        # Process assertions: filter to get failed assertions (condition = false)
        failedAssertions = lib.filter (x: !x.condition) systemArgs.config.assertions;
        assertionMessages = lib.concatMapStringsSep "\n" (x: "- ${x.message}") failedAssertions;
      in
      {
        # Collect warnings from packages
        warnings = lib.flatten (
          lib.map (package: [
            {
              condition = package.config.source.hash == "" && package.config.source.path == null;
              message = ''
                Package '${package.config.pname}': source.hash is empty.
                Correct hash will be printed in the error message when package is built.
              '';
            }
            {
              condition = package.config.license == [ ];
              message = ''
                Package '${package.config.pname}': license is empty.
              '';
            }
          ]) (lib.attrValues systemArgs.config.evals.packages)
        );

        # Collect assertions from packages
        assertions = lib.flatten (
          map (
            package:
            let
              builders = lib.filterAttrs (name: _: lib.hasSuffix "Builder" name) package.config.build;
              builderNames = map (name: "build." + name) (lib.attrNames builders);

              enabledBuilders = lib.filterAttrs (_: b: b.enable) builders;
              enabledBuilderNames = map (name: "build." + name) (lib.attrNames enabledBuilders);

              enabledBuildersCount = lib.length enabledBuilderNames;
            in
            [
              {
                condition =
                  !(
                    package.config.source.git == null
                    && package.config.source.url == null
                    && package.config.source.path == null
                  );
                message = ''
                  Package '${package.config.pname}': one of sources options must be defined.
                  Available options: source.git, source.url, or source.path.
                '';
              }
              {
                condition = !(enabledBuildersCount != 1);
                message = ''
                  Package '${package.config.pname}': only one builder can be enabled at a time.
                  Enabled options: ${lib.concatStringsSep ", " enabledBuilderNames}.
                '';
              }
              {
                condition = !(enabledBuildersCount == 0);
                message = ''
                  Package '${package.config.pname}': one of builder options must be enabled.
                  Available options: ${lib.concatStringsSep ", " builderNames}.
                '';
              }
            ]
          ) (lib.attrValues systemArgs.config.evals.packages)
        );

        # Evaluation check: show warnings first, then throw on failed assertions
        _module.check =
          if showWarnings then
            if failedAssertions != [ ] then throw "\nFailed assertions:\n${assertionMessages}" else true
          else
            true;
      };
  });
}
