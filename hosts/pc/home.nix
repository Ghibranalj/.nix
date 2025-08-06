{ config, lib, pkgs, ... }: {
  gnome.enable = true;
  hyprland.enable = true;
  hyprland.caffeineOnStartup = true;
  hyprland.mouseSensitivity = -0.9;
  hyprland.startupCmds = [
    "noisetorch -i alsa_input.usb-Generalplus_Usb_Audio_Device-00.mono-fallback"
  ];
  alacritty.enable = true;

  gtk-theme.enable = true;
  doom.mode = "gui";
  doom.fontSize.normal = 14;
  doom.fontSize.big = 16;

}
