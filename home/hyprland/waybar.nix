{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.hyprland.enable {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          output = [ "*" ];
          layer = "top";
          position = "top";
          height = 30;
          modules-left = [ "hyprland/workspaces" ];
          modules-right = [
            "custom/notification"
            "custom/caffeine"
            "bluetooth"
            "pulseaudio"
            "custom/network"
            "custom/battery"
          ];
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
            "format" = "{icon}";
            "format-icons" = {
              "notification" = "";
              "none" = "";
              "dnd-notification" = "";
              "dnd-none" = "";
              "inhibited-notification" = "";
              "inhibited-none" = "☰";
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
          "custom/battery" = {
            "exec" = "${../files/battery.sh}";
            "return-type" = "json";
            "interval" = 10;
            "format" = "{}";
            "tooltip" = true;
            "on-click" = "swaync-client -t -sw";
            "on-right-click" = "gnome-power-statistics";
          };
          "bluetooth" = {
            "format" = "󰂯";
            "format-disabled" = "";
            "format-off" = "";
            "format-connected" = "󰂱 {num_connections}";
            "on-click" = "swaync-client -t -sw";
            "on-click-right" = "blueman-manager";
            "escape" = true;
          };
          "custom/network" = {
            "exec" = "${../files/network.sh}";
            "return-type" = "json";
            "interval" = 5;
            "format" = "{}";
            "on-click" = "swaync-client -t -sw";
            "on-click-right" = "nm-connection-editor";
            "escape" = true;
          };
          "pulseaudio" = {
            "scroll-step" = 5;
            "format" = "<span size='110%'>{icon}</span>";
            "format-bluetooth" = "<span size='110%'>{icon}</span>";
            "format-muted" = "󰝟"; # Muted icon
            "format-icons" = {
              "headphone" = "󰋋";
              "hands-free" = "󰋋";
              "headset" = "󰋋";
              "phone" = "󰏲";
              "portable" = "󰏲";
              "car" = "󰏲";
              "default" = [ "󰕿" "󰖀" "󰕾" ]; # Low, medium, high volume icons
            };
            "on-click" = "swaync-client -t -sw";
            "on-click-right" = "pavucontrol";
            "tooltip-format" = "{desc} {volume}%";
            "escape" = true;
          };
          "custom/caffeine" = {
            "format" = "{icon}";
            "format-icons" = {
              "activated" = "󰅶";
              "deactivated" = "";
            };
            "on-click" = "swaync-client -t -sw";
            "on-click-right" = "${../files/caffeine.sh}";
            "return-type" = "json";
            "exec" = "${
                ../files/caffeine.sh
              } status | grep -q 'true' && echo '{\"text\":\"activated\",\"alt\":\"activated\",\"tooltip\":\"Caffeine: activated\"}' || echo '{\"text\":\"deactivated\",\"alt\":\"deactivated\",\"tooltip\":\"Caffeine: deactivated\"}'";
            "interval" = 1;
            "escape" = true;
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
          font-family: Source Code Pro;
          font-size: 14px;
          min-height: 0;
        }

        window#waybar {
          background: #1a1a1a;
          color: #ffffff;
        }

        #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: #ffffff;
          border-top: 2px solid transparent;
        }

        #workspaces button.persistent {
            color: #FF0000;
            font-size: 12px;
        }

        #workspaces button.focused {
          color: #ff0000;
          border-top: 2px solid #ffffff;
        }

        #workspaces button.urgent {
          color: #ff0000;
        }

        #workspaces button.empty {
            color: #666666;
        }

        #bluetooth.disabled,
        #bluetooth.off {
            opacity: 0.3;
        }

        #bluetooth,
        #custom-caffeine {
            font-size: 16px;
        }

        #bluetooth,
        #custom-notification,
        #custom-network,
        #custom-caffeine,
        #custom-battery {
            margin: 0 8px 0 8px;
        }

        #pulseaudio {
            margin: 0 4px 0 4px;
        }

        .modules-right {
            background-color: #353535;
            border-color: #4a4a4a;
            border-radius: 20px;
            padding: 4px 8px;
            margin: 4px 8px 4px 0;
        }

      '';
    };
  };
}

