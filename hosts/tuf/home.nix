{ config, lib, pkgs, ... }: {
  gnome.enable = true;
  alacritty.enable = true;

  gtk-theme.enable = true;
  doom.mode = "gui";
  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "\\\${HOME}/.steam/root/compatibilitytools.d";
  };

}
