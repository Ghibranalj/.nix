{ config, lib, pkgs, split-monitor-workspaces, hyprland, ... }:

{
  config = lib.mkIf config.hyprland.enable {
    rofi.enable = true;
    xdg.configFile."hyprpaper.conf".text = ''
      preload = ${../files/background.png}
      wallpaper = ,${../files/background.png} 
    '';

    wayland.windowManager.hyprland = {
      package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      enable = true;
      plugins = [
        split-monitor-workspaces.packages.${pkgs.stdenv.hostPlatform.system}.split-monitor-workspaces
      ];
      settings = {
        plugin = {
          split-monitor-workspaces = {
            count = 9;
            keep_focused = 0;
            enable_notifications = 1;
            enable_persistent_workspaces = 1;
          };
        };

        # Monitor configuration
        monitor = lib.mkDefault config.hyprland.monitorConfig;
        exec-once = [
          "hyprpaper -c /home/gibi/.config/hyprpaper.conf"
          "waybar"
          # "noisetorch -i -t 85"
          (lib.mkIf (config.hyprland.caffeineOnStartup)
            "caffeine-inhibit enable")
        ] ++ config.hyprland.startupCmds;

        # Environment variables
        env = [ "XCURSOR_SIZE,24" ];

        # Input configuration
        input = {
          kb_layout = "us";
          follow_mouse = 1;
          touchpad = {
            disable_while_typing = true;
            natural_scroll = true;
            middle_button_emulation = true;
          };
          sensitivity = config.hyprland.mouseSensitivity;
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
        workspace = [
          "special:gromit, gapsin:0, gapsout:0, on-created-empty: gromit-mpx -a"
          # Your other workspace rules...
        ];

        windowrule = [
          # Your other window rules...
        ];

        # Layout
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        # Gestures
        gestures = {
          gesture = [
            "3, horizontal, workspace"
            "4, down, close"
            "4, left, dispatcher, split-movetoworkspacesilent, -1"
            "4, right, dispatcher, split-movetoworkspacesilent, +1"
            "3, up, dispatcher, exec, YOFF=120px COL=3 ROW=10 WIDTH=1000px HEIGHT=500px rofi -location 0 -show drun -click-to-exit"
          ];
        };

        # Keybindings (DWM style)
        "$mod" = "SUPER";
        "$nomod" = "CTRL ALT";

        bind = [
          # DWM-style basic bindings
          "$mod SHIFT, Return, exec, alacritty" # spawn terminal
          "$mod, Q, killactive," # close window
          "$mod SHIFT, E, exit," # quit dwm/hyprland

          "$nomod, SPACE, exec,YOFF=120px rofi -location 2  -show drun" # alternative launcher
          "$nomod, Return, exec, emacsclient -c" # alternative launcher
          "$nomod, T, exec, alacritty" # alternative launcher
          "$nomod, equal, exec, ${../files/volumes.sh} up"
          "$nomod, minus, exec, ${../files/volumes.sh} down"

          "$nomod, 0, exec, ${../files/volumes.sh} mute"

          "$nomod, P, exec, ${../files/brightness.sh} up"

          "$nomod, O, exec, ${../files/brightness.sh} down"
          "$nomod, Delete, exec, ${../files/shutdown.sh} down"

          "$mod, Z, exec, ${../files/hyprland-zoom.sh}"
          "$mod SHIFT, Z, exec, ${../files/hyprland-zoom.sh} rigid"
          "$mod, G, exec, gromit-mpx -t ; hyprctl dispatch togglespecialworkspace gromit "

          "$mod, H, splitratio, -0.05" # increase master size
          "$mod, L, splitratio, +0.05" # decrease master size

          "$mod, N, cyclenext, , 1"
          "$mod, P, cyclenext, prev, 1"

          "$mod, I, layoutmsg, addmaster" # add a window to master area
          "$mod, D, layoutmsg, removemaster" # remove a window from master area
          "$mod, Return, layoutmsg, swapwithmaster" # zoom (swap with master)
          "$mod, T, togglefloating," # toggle floating
          "$mod, F, fullscreen, 0" # toggle fullscreen

          # DWM-style layout switching
          "$mod SHIFT, Space, togglefloating," # toggle floating mode

          # DWM-style monitor management
          "$mod, comma, focusmonitor, l" # focus left monitor
          "$mod, period, focusmonitor, r" # focus right monitor
          "$mod SHIFT, comma, movewindow, mon:l" # move window to left monitor
          "$mod SHIFT, period, movewindow, mon:r" # move window to right monitor

          "CTRL, R, pass, class:^(com.obsproject.Studio)$"
          "CTRL, 1, pass, class:^(com.obsproject.Studio)$"
          "CTRL, 2, pass, class:^(com.obsproject.Studio)$"
          "CTRL, 3, pass, class:^(com.obsproject.Studio)$"
          "CTRL, 4, pass, class:^(com.obsproject.Studio)$"

          # Workspace management
          "$mod, 1, split-workspace, 1"
          "$mod, 2, split-workspace, 2"
          "$mod, 3, split-workspace, 3"
          "$mod, 4, split-workspace, 4"
          "$mod, 5, split-workspace, 5"
          "$mod, 6, split-workspace, 6"
          "$mod, 7, split-workspace, 7"
          "$mod, 8, split-workspace, 8"
          "$mod, 9, split-workspace, 9"

          # Move windows to workspaces silently
          "$mod SHIFT, 1, split-movetoworkspacesilent, 1"
          "$mod SHIFT, 2, split-movetoworkspacesilent, 2"
          "$mod SHIFT, 3, split-movetoworkspacesilent, 3"
          "$mod SHIFT, 4, split-movetoworkspacesilent, 4"
          "$mod SHIFT, 5, split-movetoworkspacesilent, 5"
          "$mod SHIFT, 6, split-movetoworkspacesilent, 6"
          "$mod SHIFT, 7, split-movetoworkspacesilent, 7"
          "$mod SHIFT, 8, split-movetoworkspacesilent, 8"
          "$mod SHIFT, 9, split-movetoworkspacesilent, 9"

          # DWM-style view all tags
          "$mod, 0, togglespecialworkspace" # toggle special workspace
          "$mod SHIFT, 0, movetoworkspace, special" # move to special workspace

          # Additional useful bindings
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

      };
    };
  };
}
