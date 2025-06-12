{ config, pkgs, lib, inputs, ... }: {

  gui.enable = true;
  grub.enable = true;
  gnome.enable = true;
  programs.hyprland.enable = true;
  powerconf.enable = true;
  powerconf.saver.enable = true;
  evdev-keymapper.enable = true;
  dev.enable = true;
  winbox.enable = true;
  libvirt.enable = true;

  networking.hostName = "CreeprTUF"; # Define your hostname.

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
  };

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };

    amdgpuBusId = "pci:05:0:0";
    nvidiaBusId = "pci:01:0:0";
  };

  gaming.enable = true;

  specialisation = {
    gaming.configuration = {
      hardware.nvidia.prime = {
        offload = {
          enable = lib.mkForce false;
          enableOffloadCmd = lib.mkForce false;
        };
        sync.enable = lib.mkForce true;
      };
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  networking.firewall.enable = false;
}
