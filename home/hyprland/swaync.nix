{ config, pkgs, lib, ... }: {
  services.swaync = {
    enable = true;
    settings = {
      "$schema" = "/etc/xdg/swaync/configSchema.json";
      positionX = "right";
      positionY = "top";
      control-center-margin-top = 15;
      control-center-margin-bottom = 15;
      control-center-margin-right = 15;
      control-center-margin-left = 15;
      notification-icon-size = 24;
      notification-body-image-height = 100;
      notification-body-image-width = 300;
      timeout = 1;
      timeout-low = 5;
      timeout-critical = 5;
      fit-to-screen = false;
      control-center-width = 450;
      control-center-height = 900;
      notification-window-width = 450;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      script-fail-notify = true;
      widgets = [
        "buttons-grid"
        "mpris"
        (lib.mkIf (config.hyprland.brightnessDevice != null) "backlight")
        "volume"
        "dnd"
        "title"
        "notifications"
      ];
      widget-config = {
        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = "Clear";
        };
        dnd = { text = "DND Mode"; };
        label = {
          max-lines = 1;
          text = "Notifications";
        };
        mpris = {
          image-size = 96;
          image-radius = 12;
        };
        volume = { label = " 󰕾 "; };
        backlight = lib.mkIf (config.hyprland.brightnessDevice != null) {
          device = config.hyprland.brightnessDevice;
          label = "󰃟";
        };
        buttons-grid = {
          actions = [
            {
              label = "󰝟";
              command = "pamixer -t";
              update-command = "pamixer --get-mute";
              type = "toggle";
              active = true;
            }
            {
              label = "󰕾";
              command = "${../files/rofi-modi.sh} ${../files/pulseaudio}";
            }
            {
              label = "";
              command = "${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnect-app";
            }
            {
              label = "󰅶";
              type = "toggle";
              active = true;
              command = "${../files/caffeine-inhibit}";
              update-command = "${../files/caffeine-inhibit} swaync";
            }
            {
              label = "󰛳";
              command =
                "${pkgs.bash}/bin/bash -c 'HEIGHT=80% ${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu'";
              update-command =
                "nmcli -t -f STATE general | grep -q 'connected' && echo 'true' || echo 'false'";
              type = "toggle";
              active = true;
            }
            {
              label = "󰹗";
              command = "swaync-client -cp && ${../files/screenshot.sh}";
            }
            {
              label = "";
              command = "${../files/rofi-modi.sh} ${../files/vm.sh}";
            }
            {
              label = "󰂯";
              type = "toggle";
              active = true;
              update-command =
                "bluetoothctl show | grep -i powered | grep -i yes && echo 'true' || echo 'false'";
              command = "${../files/rofi-modi.sh} ${../files/bluetooth}";
            }
            {
              label = "";
              command = "alacritty";
            }
            {
              label = "⏻";
              command = "swaync-client -cp && ${../files/shutdown.sh}";
            }
          ];
        };
      };
    };

    style = builtins.readFile ../files/swaync.css;
  };
}
