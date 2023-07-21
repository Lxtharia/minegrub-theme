{
  description = "flake support minegrub theme nixos module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    {
      nixosModules.default = { config, pkgs, ... }:
        let
          cfg = config.boot.loader.grub.minegrub-theme;
          lib = nixpkgs.lib;
          minegrub-theme = pkgs.stdenv.mkDerivation {
            name = "minegrub-theme";
            src = "${self}";
            installPhase = ''
              mkdir -p $out/grub/themes/minegrub
              cp *.png $out/grub/themes/minegrub
              cp *.pf2 $out/grub/themes/minegrub
              cp theme.txt $out/grub/themes/minegrub
            '';
          };
        in
        {
          options = {
            boot.loader.grub.minegrub-theme = {
              enable = lib.mkOption {
                default = false;
                example = true;
                type = lib.types.bool;
                description = ''
                  Enable minegrub theme
                '';
              };
            };
          };
          config = lib.mkIf cfg.enable {
            boot.loader.grub = {
              theme = "${minegrub-theme}/grub/themes/minegrub";
              splashImage = "${minegrub-theme}/grub/themes/minegrub/background.png";
            };
          };
        };
    };
}
