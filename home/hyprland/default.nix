{ config, lib, pkgs, ... }:

{
  options = with lib; {
    hyprland.enable = mkEnableOption "enable hyprland";
    hyprland.mouseSensitivity = mkOption {
      type = types.float;
      default = 0.0;
      description = "Mouse sensitivity for Hyprland.";
    };
    hyprland.monitorConfig = mkOption {
      type = types.listOf types.str;
      default = [ "HDMI-A-1,1920x1080@100,0x0,1" "DP1,1920x1080@100,1920x0,1" ];
      description = "List of monitor configurations for Hyprland.";
    };

    hyprland.caffeineOnStartup = mkOption {
      type = types.bool;
      default = false;
      description = "Enable or disable caffeine on startup.";
    };

    # string or null
    hyprland.brightnessDevice = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Device to control brightness, e.g., 'amdgpu_bl0'. Run ls /sys/class/backlight";
      example = "amdgpu_bl0";
    };

    hyprland.startupCmds = mkOption {
      type = types.listOf types.str;
      default = [ "" ];
      description = "List of command to run when hyprland starts";
    };
  };

  imports = [
    ./hyprland.nix # hyprland
    ./waybar.nix # waybar
    ./swaync.nix # sway notification center
  ];

  config = lib.mkIf config.hyprland.enable {
    programs.hyprlock.enable = true;
    services = {
      caffeine = { enable = false; };
      udiskie = { enable = true; };
      kdeconnect = { enable = true; };
      hyprsunset = {
        enable = true;
        transitions = {
          sunrise = {
            calendar = "*-*-* 06:00:00";
            requests = [[ "temperature" "6500" ]];
          };
          sunset = {
            calendar = "*-*-* 19:00:00";
            requests = [[ "temperature" "4900" ]];
          };
        };
      };
      hypridle = {
        enable = true;
        settings = {
          general = {
            after_sleep_cmd = "hyprctl dispatch dpms on";
            ignore_dbus_inhibit = false;
            lock_cmd = "hyprlock";
          };
          listener = [
            {
              timeout = 180;
              on-timeout = "${
                  ../files/caffeine-inhibit
                } isoff && brightnessctl -s && brightnessctl set 0%";
              on-resume =
                "${../files/caffeine-inhibit} isoff && brightnessctl -r";
            }
            {
              timeout = 300;
              on-timeout = "${../files/caffeine-inhibit} isoff && hyprlock";
            }
            {
              timeout = 330;
              on-timeout = "${
                  ../files/caffeine-inhibit
                } isoff && hyprctl dispatch dpms off";
              on-resume = "${
                  ../files/caffeine-inhibit
                } isoff && hyprctl dispatch dpms on && brightnessctl -r";
            }
            {
              timeout = 1200;
              on-timeout = "${
                  ../files/caffeine-inhibit
                } isoff && upower -i $(upower -e | grep 'BAT') | grep 'state' | grep -q discharging && systemctl hibernate --force";
            }
          ];
        };
      };
    };

    services.hyprpolkitagent.enable = true;
    home.packages = with pkgs; [
      # Core Wayland components
      waybar
      rofi-wayland-unwrapped
      hyprpaper
      swaynotificationcenter

      nautilus

      # Utilities
      wl-clipboard
      grim
      slurp
      swappy
      brightnessctl
      wireplumber # for wpctl audio control
      ponymix
      pulseaudio
      bc
      pamixer
      libnotify
      jq
      wirelesstools
      wf-recorder
      swayidle
      gromit-mpx

      # Bluetooth
      bluez
      bluez-tools
      blueman

      #networking
      networkmanager_dmenu
      kdePackages.kdeconnect-kde

      #caffeine
      (writeScriptBin "caffeine-inhibit"
        (builtins.readFile ../files/caffeine-inhibit))
    ];

    xdg.configFile."networkmanager-dmenu/config.ini".text = ''
      [dmenu]
      dmenu_command = rofi -location 3 
      active_chars = ==
      highlight = True
      highlight_fg =
      highlight_bg =
      highlight_bold = True
      compact = True 
      pinentry = None
      wifi_icons = 󰤯󰤟󰤢󰤥󰤨
      format = {name:<{max_len_name}s}  {sec:<{max_len_sec}s} {icon:>4}
      list_saved = False
      prompt = Networks

      [dmenu_passphrase]
      obscure = False
      obscure_color = #222222

      [pinentry]
      description = Get network password
      prompt = Password:

      [editor]
      terminal = ${pkgs.alacritty}/bin/alacritty
      gui_if_available = True
      gui = ${pkgs.networkmanagerapplet}/bin/nm-connection-editor

      [nmdm]
      rescan_delay = 5
    '';

  };

}

