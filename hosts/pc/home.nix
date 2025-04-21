{ config, lib, pkgs, ... }:
{
  gnome.enable = true;
  alacritty.enable = true;
  
  gtk-theme.enable = true;
  doom.mode = "gui";
  doom.fontSize.normal = 15;
  doom.fontSize.big = 20;
}
