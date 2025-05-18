{ config, lib, pkgs, ... }: {
  gnome.enable = true;
  alacritty.enable = true;

  gtk-theme.enable = true;
  doom.mode = "gui";

  doom.fontSize.normal = "15";
  doom.fontSize.big = "18";
  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "\\\${HOME}/.steam/root/compatibilitytools.d";
  };

}
