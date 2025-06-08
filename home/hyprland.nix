{ config, lib, pkgs, ... }:

{
  options = with lib; { hyprland.enable = mkEnableOption "enable hyprland"; };

  config = lib.mkIf config.hyprland.enable {
    rofi.enable = true;
    # Enable Hyprland
    wayland.windowManager.hyprland = {
      enable = true;
      plugins = with pkgs.hyprlandPlugins; [ hyprsplit ];
      settings = {
        plugin = { hyprsplit = { num_workspaces = 9; }; };

        # Monitor configuration
        monitor = [
          "HDMI-A-1,1920x1080@100,0x0,1"
          "DP1,1920x1080@100,1920x0,1"
          #
        ];

        # Startup applications
        exec-once = [ "waybar" "hyprpaper" "dunst" ];

        # Environment variables
        env = [ "XCURSOR_SIZE,24" "QT_QPA_PLATFORMTHEME,qt5ct" ];

        # Input configuration
        input = {
          kb_layout = "us";
          follow_mouse = 1;
          touchpad = { natural_scroll = false; };
          sensitivity = 0;
        };

        # General settings
        general = {
          gaps_in = 2;
          gaps_out = 5;
          border_size = 1;
          "col.active_border" = "rgba(585858ff)";
          "col.inactive_border" = "rgba(212121ff)";
          layout = "master";
          allow_tearing = false;
        };

        # Decoration
        decoration = {
          rounding = 10;
          blur = { enabled = false; };
        };

        # Animations
        animations = { enabled = false; };

        # Layout
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        # Gestures
        gestures = { workspace_swipe = true; };

        # Keybindings (DWM style)
        "$mod" = "SUPER";
        "$nomod" = "CTRL ALT";

        bind = [
          # DWM-style basic bindings
          "$mod SHIFT, Return, exec, alacritty" # spawn terminal
          "$mod, Return, exec, alacritty" # spawn terminal (alternative)
          "$mod, Q, killactive," # close window
          "$mod SHIFT, E, exit," # quit dwm/hyprland
          "$mod, P, exec, rofi -show drun" # dmenu equivalent
          "$mod, D, exec, rofi -show drun" # alternative launcher

          "$nomod, SPACE, exec, rofi -show drun" # alternative launcher
          "$nomod, Return, exec, emacsclient -c" # alternative launcher
          "$nomod, T, exec, alacritty" # alternative launcher

          # DWM-style focus management
          "$mod, J, cyclenext," # focus next window
          "$mod, K, cyclenext, prev" # focus previous window
          "$mod SHIFT, J, swapnext," # swap with next window
          "$mod SHIFT, K, swapnext, prev" # swap with previous window

          # DWM-style layout management  
          "$mod, I, splitratio, +0.05" # increase master size
          "$mod, D, splitratio, -0.05" # decrease master size
          "$mod, Return, layoutmsg, swapwithmaster" # zoom (swap with master)
          "$mod, T, togglefloating," # toggle floating
          "$mod, F, fullscreen, 0" # toggle fullscreen

          # DWM-style layout switching
          "$mod, Space, layoutmsg, togglesplit" # toggle layout
          "$mod SHIFT, Space, togglefloating," # toggle floating mode

          # DWM-style monitor management
          "$mod, comma, focusmonitor, l" # focus left monitor
          "$mod, period, focusmonitor, r" # focus right monitor
          "$mod SHIFT, comma, movewindow, mon:l" # move window to left monitor
          "$mod SHIFT, period, movewindow, mon:r" # move window to right monitor

          "SUPER, 1, split:workspace, 1"
          "SUPER, 2, split:workspace, 2"
          "SUPER, 3, split:workspace, 3"
          "SUPER, 4, split:workspace, 4"
          "SUPER, 5, split:workspace, 5"
          "SUPER, 6, split:workspace, 6"
          "SUPER, 7, split:workspace, 7"
          "SUPER, 8, split:workspace, 8"
          "SUPER, 9, split:workspace, 9"

          # Move windows to workspaces silently
          "SUPER SHIFT, 1, split:movetoworkspacesilent, 1"
          "SUPER SHIFT, 2, split:movetoworkspacesilent, 2"
          "SUPER SHIFT, 3, split:movetoworkspacesilent, 3"
          "SUPER SHIFT, 4, split:movetoworkspacesilent, 4"
          "SUPER SHIFT, 5, split:movetoworkspacesilent, 5"
          "SUPER SHIFT, 6, split:movetoworkspacesilent, 6"
          "SUPER SHIFT, 7, split:movetoworkspacesilent, 7"
          "SUPER SHIFT, 8, split:movetoworkspacesilent, 8"
          "SUPER SHIFT, 8, split:movetoworkspacesilent, 9"

          # DWM-style view all tags
          "$mod, 0, workspace, special" # view special workspace
          "$mod SHIFT, 0, movetoworkspace, special" # move to special workspace

          # Additional useful bindings
          "$mod, B, exec, firefox" # browser
          "$mod, E, exec, nautilus" # file manager
          "$mod SHIFT, R, exec, hyprctl reload" # reload config

          # Volume and brightness (common additions)
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ +5%"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ -5%"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86MonBrightnessUp, exec, brightnessctl set +10%"
          ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"

          # Screenshot bindings
          ", Print, exec, grim"
          ''$mod, Print, exec, grim -g "$(slurp)"''
        ];

        # Mouse bindings
        bindm =
          [ "$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow" ];

        # Window rules
        # windowrulev2 = [ "suppress_events_fullscreen, class:.*" ];
      };
    };

    # Required packages
    home.packages = with pkgs; [
      # Core Wayland components
      waybar
      rofi-wayland-unwrapped
      dunst
      hyprpaper

      # Terminal and basic apps
      alacritty
      nautilus
      firefox

      # Utilities
      wl-clipboard
      grim
      slurp
      swappy
      brightnessctl
      wireplumber # for wpctl audio control
    ];

    # polybar config here

    # Additional Hyprland services
    services.dunst.enable = true;
  };
}
