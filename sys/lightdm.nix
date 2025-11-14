{ config, lib, pkgs, ... }:
let
  sddm-materia-dark = pkgs.stdenv.mkDerivation {
    name = "sddm-materia-dark";
    src = pkgs.fetchFromGitHub {
      owner = "Ghibranlj";
      repo = "materia-kde";
      rev = "d544aeb52e0ddf764c58763ed7d6b19176575b7e";
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
  };
in {

  options = with lib; { lightdm.enable = mkEnableOption "enable lightdm"; };

  config = lib.mkIf config.lightdm.enable {

    services.xserver = {
      enable = true;
      displayManager.gdm.enable = lib.mkForce false;
    };
    # Install the theme globally

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "materia-dark";
    };

    programs.hyprland.enable = lib.mkDefault (!config.gnome.enable);

    environment.systemPackages = with pkgs; [
      sddm-materia-dark
      libsForQt5.qt5.qtgraphicaleffects
      libsForQt5.qt5.qtquickcontrols2
      libsForQt5.qt5.qtsvg
    ];
  };
}
