{ config, lib, pkgs, ... }:
{
  gnome.enable = true;
  hyprland.enable = true;
  alacritty.enable = true;
  
  gtk-theme.enable = true;
  doom.mode = "gui";
  doom.fontSize.normal = 14;
  doom.fontSize.big = 16;

}
