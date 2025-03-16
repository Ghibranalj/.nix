{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
  ] ++ (with pkgs.gnomeExtensions; [
    caffeine
    blur-my-shell
    battery-time-2
    hibernate-status-button
    gsconnect
  ]);
  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "blur-my-shell@aunetx" "caffeine@patapon.info" "batterytime@typeof.pw"
        "hibernate-status@dromi"
      ];
    };
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = false;
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
      help = [];
    };
    # Define each custom keybinding under its full path
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Control><Alt>t";
      command = "alacritty";
      name = "terminal";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Control><Alt>Return";
      command = "emacsclient -c";
      name = "emacs";
    };
  };

}
