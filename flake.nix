{
  description = "flake support minegrub theme nixos module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs.lib) genAttrs optionals optionalString;
      eachSystem = f: genAttrs
        [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-darwin"
          "x86_64-linux"
        ]
        (system: f nixpkgs.legacyPackages.${system});

      minegrub =
        {
          pkgs,
          splash ? "",
          background ? "",
          customSplash ? splash != "",
          boot-options-count,
          boot-menu-width ? 600,
          boot-menu-height ? 500,
          ...
        }:
        pkgs.stdenv.mkDerivation {
          name = "minegrub-theme";
          src = "${self}";

          buildInputs = with pkgs; optionals customSplash [
            fastfetch
            (python3.withPackages (p: [ p.pillow ]))
          ];

          patchPhase = ''
            sed -i '$d' minegrub/update_theme.py

            top_value=$((170 + (${toString boot-options-count} - 2) * 72))
            menu_width=${toString boot-menu-width}
            menu_height=${toString boot-menu-height}
            menu_half=$((menu_width / 2))
            menu_left=$((menu_half - 3))
            sed -i '/^+ image {/,/^}$/s/top = 40%+[0-9]\+/top = 40%+'"$top_value"'/' minegrub/theme.txt
            sed -i '0,/left = 50%-297/s//left = 50%-'"$menu_left"'/' minegrub/theme.txt
            sed -i '0,/left = 50%-300/s//left = 50%-'"$menu_half"'/' minegrub/theme.txt
            sed -i '/^+ boot_menu {/,/^}$/s/width = 600/width = '"$menu_width"'/' minegrub/theme.txt
            sed -i '/^+ boot_menu {/,/^}$/s/height = 500/height = '"$menu_height"'/' minegrub/theme.txt
          '';

          buildPhase = optionalString customSplash ''
            python minegrub/update_theme.py "${background}" "${splash}"
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
          inherit (nixpkgs.lib) mkIf mkOption mkOverride types;
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
              console-background = mkOption {
                default = "background_options/dirt.png";
                example = "background_options/dirt.png";
                type = types.str;
                description = ''
                  Optional background shown in the GRUB console opened with
                  `c`. Relative paths are resolved from the Minegrub source;
                  the Minegrub background is used when this is empty.
                '';
              };
              boot-menu-width = mkOption {
                default = 600;
                example = 700;
                type = types.number;
                description = ''
                  Width of the boot menu in pixels.
                '';
              };
              boot-menu-height = mkOption {
                default = 500;
                example = 600;
                type = types.number;
                description = ''
                  Height of the boot menu in pixels.
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
              background = mkOption {
                default = "background_options/1.8  - [Classic Minecraft].png";
                example = "/path/to/background.png";
                type = types.str;
                description = ''
                  Path to background image.
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
                  background = cfg.background;
                  boot-options-count = cfg.boot-options-count;
                  boot-menu-width = cfg.boot-menu-width;
                  boot-menu-height = cfg.boot-menu-height;
                };
              in
              {
                theme = "${minegrub-theme}/grub/themes/minegrub";
                splashImage =
                  if cfg.console-background == "" then
                    mkOverride 900 "${minegrub-theme}/grub/themes/minegrub/background.png"
                  else if builtins.substring 0 1 cfg.console-background == "/" then
                    cfg.console-background
                  else
                    "${self}/${cfg.console-background}";
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
