{ config, lib, pkgs, ... }:

{
  options = with lib; { gnome.enable = mkEnableOption "gnome user"; };

  config = lib.mkIf config.gnome.enable {
    home.packages = with pkgs;
      [ ] ++ (with pkgs.gnomeExtensions; [
        caffeine
        blur-my-shell
        battery-time-2
        hibernate-status-button
        gsconnect
        boost-volume
      ]);

    dconf.settings = with lib.hm.gvariant; {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          "blur-my-shell@aunetx"
          "caffeine@patapon.info"
          "batterytime@typeof.pw"
          "hibernate-status@dromi"
          "gsconnect@andyholmes.github.io"
          boost-volume.extensionUuid
        ];
      };
      "org/gnome/shell/extensions/blur-my-shell/panel" = { blur = false; };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        ];
        help = [ ];
        search = [ "<Control><Alt>space" ];
      };
      # Define each custom keybinding under its full path
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
        {
          binding = "<Control><Alt>t";
          command = "alacritty";
          name = "terminal";
        };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" =
        {
          binding = "<Control><Alt>Return";
          command = "emacsclient -c";
          name = "emacs";
        };
      "org/gnome/desktop/background" = {
        color-shading-type = "solid";
        picture-options = "zoom";
        picture-uri = "file://${./files/background.png}";
        picture-uri-dark = "file://${./files/background.png}";
        primary-color = "#FFCB6B";
      };
      "org/gnome/desktop/peripherals/mouse" = {
        accel-profile = "flat";
        natural-scroll = false;
        speed = -0.37593984962406013;
      };
      "org/gnome/desktop/wm/preferences".num-workspaces = 9;
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/mutter".dynamic-workspaces = false;
      "org/gnome/desktop/wm/keybindings" = {
        # Custom keybinding to close a window
        close = [ "<Super>q" ];
        # Keybindings to move window to specific workspaces
        "move-to-workspace-1" = [ "<Shift><Super>1" ];
        "move-to-workspace-2" = [ "<Shift><Super>2" ];
        "move-to-workspace-3" = [ "<Shift><Super>3" ];
        "move-to-workspace-4" = [ "<Shift><Super>4" ];
        "move-to-workspace-5" = [ "<Shift><Super>5" ];
        "move-to-workspace-6" = [ "<Shift><Super>6" ];
        "move-to-workspace-7" = [ "<Shift><Super>7" ];
        "move-to-workspace-8" = [ "<Shift><Super>8" ];
        "move-to-workspace-9" = [ "<Shift><Super>9" ];

        # Keybindings to switch to specific workspaces
        "switch-to-workspace-1" = [ "<Super>1" ];
        "switch-to-workspace-2" = [ "<Super>2" ];
        "switch-to-workspace-3" = [ "<Super>3" ];
        "switch-to-workspace-4" = [ "<Super>4" ];
        "switch-to-workspace-5" = [ "<Super>5" ];
        "switch-to-workspace-6" = [ "<Super>6" ];
        "switch-to-workspace-7" = [ "<Super>7" ];
        "switch-to-workspace-8" = [ "<Super>8" ];
        "switch-to-workspace-9" = [ "<Super>9" ];
      };
    };
  };
}
