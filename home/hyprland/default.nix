{ config, lib, pkgs, ... }:

{
  options = with lib; {
    hyprland.enable = mkEnableOption "enable hyprland";
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
  ];

  config = lib.mkIf config.hyprland.enable {

    services = {
      caffeine = { enable = true; };
      udiskie = { enable = true; };
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

      # Bluetooth
      bluez
      bluez-tools
      blueman

      #lock
      xsecurelock
    ];
  };
}

