{ config, lib, pkgs, ... }:

{

  options = with lib; { lightdm.enable = mkEnableOption "enable lightdm"; };

  config = lib.mkIf config.lightdm.enable {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "materia-dark";
      package = pkgs.sddm.override {
        themes = [
          (pkgs.stdenv.mkDerivation {
            name = "sddm-materia-dark";
            src = pkgs.fetchFromGitHub {
              owner = "PapirusDevelopmentTeam";
              repo = "materia-kde";
              rev = "6cc4c1867c78b62f01254f6e369ee71dce167a15";
              sha256 = "sha256-tZWEVq2VYIvsQyFyMp7VVU1INbO7qikpQs4mYwghAVM=";
            };
            installPhase = ''
              mkdir -p $out/share/sddm/themes
              cp -r sddm/themes/materia-dark $out/share/sddm/themes/

              # Replace the background image with custom one
              rm $out/share/sddm/themes/materia-dark/images/background.png
              cp ${
                ./files/background.png
              } $out/share/sddm/themes/materia-dark/images/background.png
            '';
          })
        ];
      };
    };
    programs.hyprland.enable = true;
  };
}
