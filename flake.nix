{
  description = "flake support minegrub theme nixos module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs.lib) genAttrs optional;
      eachSystem = f: genAttrs
        [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-darwin"
          "x86_64-linux"
        ]
        (system: f nixpkgs.legacyPackages.${system});

      minegrub =
        { pkgs, splash ? "", customSplash ? splash != "", boot-options-count, ... }:
        pkgs.stdenv.mkDerivation {
          name = "minegrub-theme";
          src = "${self}";

          buildInputs = optional customSplash
            [
              (pkgs.python3.withPackages
                (p: [ p.pillow ]))
            ];

          patchPhase = ''
            sed -i '$d' minegrub/update_theme.py

            top_value=$((170 + (${toString boot-options-count} - 2) * 72))
            sed -i '/^+ image {/,/^}$/s/top = 40%+[0-9]\+/top = 40%+'"$top_value"'/' minegrub/theme.txt
          '';

          buildPhase = optional customSplash ''
            python minegrub/update_theme.py "${splash}"
          '';

          installPhase = ''
            cd minegrub
            mkdir -p $out/grub/themes/minegrub
            cp *.png $out/grub/themes/minegrub
            cp *.pf2 $out/grub/themes/minegrub
            cp theme.txt $out/grub/themes/minegrub
          '';
        };
    in
    {
      nixosModules.default = { config, pkgs, ... }:
        let
          cfg = config.boot.loader.grub.minegrub-theme;
          inherit (nixpkgs.lib) mkOption types mkIf;
        in
        {
          options = {
            boot.loader.grub.minegrub-theme = {
              boot-options-count = mkOption {
                default = 4;
                example = 4;
                type = types.number;
                description = ''
                  Number of boot options.
                '';
              };
              splash = mkOption {
                default = "deleting garbage...";
                example = "Infinite recursion";
                type = types.str;
                description = ''
                  Splash text on logo.
                '';
              };
              enable = mkOption {
                default = false;
                example = true;
                type = types.bool;
                description = ''
                  Enable minegrub theme.
                '';
              };
            };
          };
          config = mkIf cfg.enable {
            boot.loader.grub =
              let
                minegrub-theme = minegrub {
                  inherit pkgs;
                  splash = cfg.splash;
                  boot-options-count = cfg.boot-options-count;
                };
              in
              {
                theme = "${minegrub-theme}/grub/themes/minegrub";
                splashImage = "${minegrub-theme}/grub/themes/minegrub/background.png";
              };
          };
        };

      packages = eachSystem
        (pkgs: {
          default = minegrub {
            inherit pkgs;
            # splash = "custom splash text";
          };
        });
    };
}
