{ config, lib, pkgs, ... }:
{
  gnome.enable = false;
  hyprland.enable = true;
  hyprland.monitorConfig = [ ", preferred, auto, 1" ];

  hyprland.brightnessDevice = "intel_backlight";

  alacritty.enable = true;
  
  gtk-theme.enable = true;
  doom.mode = "gui";
}
