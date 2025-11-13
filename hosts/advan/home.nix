{ config, lib, pkgs, ... }:
{
  gnome.enable = false;
  hyprland.enable = true;
  hyprland.monitorConfig = [ ", preferred, auto, 1" ];

  hyprland.brightnessDevice = "amdgpu_bl1";

  alacritty.enable = true;
  
  gtk-theme.enable = true;
  doom.mode = "gui";
}
