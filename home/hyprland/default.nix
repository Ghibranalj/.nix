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
      default = [
        "HDMI-A-1,1920x1080@100,0x0,1" # mon 1
        "DP1,1920x1080@100,1920x0,1"
      ];
      description = "List of monitor configurations for Hyprland.";
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
      caffeine = { enable = true; };
      udiskie = { enable = true; };
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
              timeout = 900;
              on-timeout = "hyprlock";
            }
            {
              timeout = 1200;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
          ];
        };
      };
    };

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
      bc
      pamixer
      libnotify
      jq
      wirelesstools
      wf-recorder

      # Bluetooth
      bluez
      bluez-tools
      blueman

      #networking
      networkmanager_dmenu

      #lock
      xsecurelock
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

