{ config, pkgs, lib, inputs, ... }: {
  gui.enable = true;

  gnome.enable = false;
  gdm.enable = true;
  powerconf.enable = true;
  powerconf.saver = {
    enable = true;
    batteryGovernor = "powersave";
    chargerGovernor = "performance";
  };
  evdev-keymapper.enable = true;
  dev.enable = true;
  winbox.enable = true;

  programs.obs-studio.enable = true;

  networking.hostName = "CreeprAir"; # Define your hostname.

  environment.systemPackages = with pkgs; [
    qemu
    # easyeffects
    #
  ];

  networking.firewall.enable = false;
}
