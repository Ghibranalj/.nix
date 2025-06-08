{ config, lib, pkgs, split-monitor-workspaces, hyprland, ... }:

{
  options = with lib; {
    hyprland.enable = mkEnableOption "enable hyprland";
    hyprland.monitorConfig = mkOption {
      type = types.listOf types.str;
      default = [
        "HDMI-A-1,1920x1080@100,0x0,1"
        "DP1,1920x1080@100,1920x0,1"
        #
      ];
      description = "List of monitor configurations for Hyprland.";
    };
  };

  config = lib.mkIf config.hyprland.enable {

    rofi.enable = true;
    xdg.configFile."hyprpaper.conf".text = ''
      preload = ${./files/background.png}
      wallpaper = ,${./files/background.png} 
    '';

    wayland.windowManager.hyprland = {
      package = hyprland.packages.${pkgs.system}.hyprland;
      enable = true;
      plugins = [
        split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
      ];
      settings = {
        plugin = {
          split-monitor-workspaces = {
            count = 9;
            keep_focused = 0;
            enable_notifications = 0;
            enable_persistent_workspaces = 1;
          };
        };

        # Monitor configuration
        monitor = lib.mkDefault config.hyprland.monitorConfig;
        # Startup applications
        exec-once =
          [ "waybar" "hyprpaper -c /home/gibi/.config/hyprpaper.conf" ];

        # Environment variables
        env = [
          "XCURSOR_SIZE,24"
          "QT_QPA_PLATFORMTHEME,gtk"
          "GTK_THEME,Adwaita-dark"
        ];

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

      };
    };

    # Required packages
    home.packages = with pkgs; [
      # Core Wayland components
      waybar
      rofi-wayland-unwrapped
      hyprpaper
      swaynotificationcenter

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
      ponymix
      pulseaudio

      # Bluetooth
      bluez
      bluez-tools
      blueman

      #lock
      xsecurelock
    ];

    services.swaync.enable = true;

    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          output = [ "*" ];
          layer = "top";
          position = "top";
          height = 30;
          modules-left = [ "hyprland/workspaces" ];
          modules-right = [ "custom/notification" "bluetooth" "pulseaudio" "custom/shutdown" ];
          modules-center = [ "clock" ];
          "hyprland/workspaces" = {
            "format" = "{icon}";
            "format-icons" = {
              "urgent" = "";
              "active" = "";
              "visible" = "";
              "default" = "";
              "empty" = "";
              "occupied" = ""; # filled small circle
            };
            "all-outputs" = false;
          };
          "custom/notification" = {
            "tooltip-format" = "{body}";
            "format" = "{icon}";
            "format-icons" = {
              "notification" = "";
              "none" = "";
              "dnd-notification" = "";
              "dnd-none" = "";
              "inhibited-notification" = "";
              "inhibited-none" = "";
              "dnd-inhibited-notification" = "";
              "dnd-inhibited-none" = "";
            };
            "return-type" = "json";
            "exec-if" = "which swaync-client";
            "exec" = "swaync-client -swb";
            "on-click" = "swaync-client -t -sw";
            "on-click-right" = "swaync-client -d -sw";
            "escape" = true;
          };
          "bluetooth" = {
            "format" = "󰂯";
            "format-disabled" = "󰂲";
            "format-connected" = "󰂱";
            "tooltip-format" = ''
              {controller_alias}	{controller_address}

              {num_connections} connected'';
            "tooltip-format-connected" = ''
              {controller_alias}	
              {num_connections} connected

              {device_enumerate}'';
            "tooltip-format-enumerate-connected" =
              "{device_alias}	{device_address}";
            "on-click" = ''
              export YOFF=27px
              export HEIGHT=50%
              export INPUT=false
              rofi -click-to-exit -location 3 -show b -modi "b:${
                ./files/bluetooth
              }"
            '';
            "on-click-right" = "blueman-manager";
          };
          "pulseaudio" = {
            "scroll-step" = 5;
            "format" = "{icon} {volume}%";
            "format-bluetooth" = "{icon} {volume}%";
            "format-muted" = "󰝟";
            "format-icons" = {
              "headphone" = "󰋋";
              "hands-free" = "󰋋";
              "headset" = "󰋋";
              "phone" = "󰏲";
              "portable" = "󰏲";
              "car" = "󰏲";
              "default" = [ "󰕿" "󰖀" "󰕾" ];
            };
            "on-click" = ''
              export YOFF=27px
              export HEIGHT=50%
              export INPUT=false
              rofi -click-to-exit -location 3 -show b -modi "b:${
                ./files/pulseaudio
              }"
            '';
            "on-click-right" = "pavucontrol";
            "tooltip-format" = "{desc} {volume}%";
          };
          "custom/shutdown" = {
            "format" = "⏻";
            "on-click" = "${./files/shutdown.sh}";
            "tooltip" = false;
          };
          "clock" = {
            "format" = "{:%H:%M}";
            "format-alt" = "{:%d %B %Y}";
            "tooltip-format" = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
          };
        };
      };

      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: "Source Code Pro";
          font-size: 16px;
          min-height: 0;
        }

        window#waybar {
          background: #1a1a1a;
          color: #ffffff;
          padding: 0 10px;
        }

        #workspaces,
        #clock,
        #pulseaudio,
        #bluetooth,
        #custom-notification {
          padding: 0 10px;
          margin: 0 5px;
        }

        #custom-shutdown {
          padding: 0 10px;
          margin: 0 5px 0 15px;
        }

        #workspaces button.persistent {
            color: yellow;
            font-size: 14px;
        }

        #workspaces button.focused {
          color: #ffffff;
          border-top: 2px solid #ffffff;
        }

        #workspaces button.urgent {
          color: #ff0000;
        }

        #workspaces button {
          color: #ffffff;
          padding: 0 8px;
        }

        #workspaces button.empty {
          color: #666666;
        }

        #custom-notification {
          padding: 0 8px;
        }

        #custom-notification.notification {
          color: #ffffff;
        }

        #custom-notification.none {
          color: #666666;
        }

        #custom-notification.dnd-notification {
          color: #ff0000;
        }

        #custom-notification.dnd-none {
          color: #666666;
        }

        #pulseaudio {
          padding: 0 7px;
        }

        #bluetooth {
          padding: 0 7px;
        }

        #clock {
          padding: 0 8px;
        }
      '';
    };
  };
}
