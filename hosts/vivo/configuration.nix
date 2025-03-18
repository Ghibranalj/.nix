# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, lib ,inputs, ... }:
{
  gui.enable = true;
  grub.enable = true;
  gnome.enable = true;
  powerconf.enable = true;
  powerconf.saver.enable = true;
  evdev-keymapper.enable = true;
  dev.enable =true;
  winbox.enable =true;

  networking.hostName = "CreepRvivo"; # Define your hostname.

  environment.systemPackages = with pkgs; [
  ];

  networking.firewall.allowedTCPPorts = [ 22 23 8080 443 1716 ];
  networking.firewall.allowedUDPPorts = [ 443 8080 1716 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

}
