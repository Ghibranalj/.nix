{ config, lib, pkgs, inputs, ... }:
let
  sddm-materia-dark = pkgs.stdenv.mkDerivation {
    name = "sddm-materia-dark";
    src = pkgs.fetchFromGitHub {
      owner = "Ghibranalj";
      repo = "materia-kde";
      rev = "d544aeb52e0ddf764c58763ed7d6b19176575b7e";
      sha256 = "1s0hyjs4wi8f2h193dvz4nyi0z4xykhh5a7klsdq5if9d7d5qivs";
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

    programs.hyprland = {
      enable = lib.mkDefault (!config.gnome.enable);
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    };

    services.displayManager.defaultSession =
      lib.mkIf (!config.gnome.enable) "hyprland";

    environment.systemPackages = with pkgs; [
      sddm-materia-dark
      libsForQt5.qt5.qtgraphicaleffects
      libsForQt5.qt5.qtquickcontrols2
      libsForQt5.qt5.qtsvg
    ];
  };
}
