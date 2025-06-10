{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.hyprland.enable {
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
          modules-right = [
            "custom/notification"
            "custom/screenshot"
            "bluetooth"
            "pulseaudio"
            # "custom/caffeine"
            "custom/shutdown"
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
          "custom/screenshot" = {
            "format" = "⛶";
            "on-click" = "${../files/screenshot.sh}";
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
                ../files/bluetooth
              }"
            '';
            "on-click-right" = "blueman-manager";
            "escape" = true;
          };
          "pulseaudio" = {
            "scroll-step" = 5;
            "format" = ''{icon} <span size="68%">{volume}%</span>'';
            "format-bluetooth" = ''{icon} <span size="68%">{volume}%</span>'';
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
                ../files/pulseaudio
              }"
            '';
            "on-click-right" = "pavucontrol";
            "tooltip-format" = "{desc} {volume}%";
            "escape" = true;
          };
          # "custom/caffeine" = {
          #   "format" = "{icon}";
          #   "format-icons" = {
          #     "activated" = "󰅶";
          #     "deactivated" = "󰶐";
          #   };
          #   "tooltip-format" = "Caffeine: {status}";
          #   "on-click" = "hyprctl dispatch dpms on";
          #   "on-click-right" = "hyprctl dispatch dpms off";
          #   "return-type" = "json";
          #   "exec" = "hyprctl monitors | grep -q 'dpmsStatus: on' && echo '{\"text\":\"activated\",\"alt\":\"activated\",\"tooltip\":\"Caffeine: activated\"}' || echo '{\"text\":\"deactivated\",\"alt\":\"deactivated\",\"tooltip\":\"Caffeine: deactivated\"}'";
          #   "interval" = 1;
          #   "escape" = true;
          # };
          "custom/shutdown" = {
            "format" = "⏻";
            "on-click" = "${../files/shutdown.sh}";
            "tooltip" = false;
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

        #bluetooth,
        #custom-screenshot,
        #pulseaudio {
            font-size: 16px;
        }

        #bluetooth,
        #custom-notification,
        #custom-screenshot,
        #pulseaudio,
        #custom-shutdown {
            margin: 0 15px 0 0;
        }

      '';
    };
  };
}

