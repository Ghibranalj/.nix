{ config, lib, pkgs, ... }:
{
  gnome.enable = true;
  alacritty.enable = true;
  gtk-theme.enable = true;
  doom.mode = "gui";
}
