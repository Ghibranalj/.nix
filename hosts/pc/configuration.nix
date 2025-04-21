{ config, lib, pkgs, ... }:

{

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  networking.hostName = "CreeprPC"; # Define your hostname.
  gui.enable = true;
  grub.enable = true;
  gnome.enable = true;
  dev.enable =true;
  winbox.enable =true;
  evdev-keymapper = {
  	enable = true;
	  device = "/dev/input/by-id/btkeyboard";
  };

  libvirt.enable = true;

  environment.systemPackages = with pkgs; [
  ];

  networking.firewall.enable = false;
  
  services.udev.extraRules = ''
    # Keyboard
    KERNEL=="event*", SUBSYSTEM=="input", ATTRS{name}=="AJAZZ K680T Keyboard", SYMLINK+="input/by-id/btkeyboard"

    # Mouse
    KERNEL=="event*", SUBSYSTEM=="input", ATTRS{name}=="Basilisk X HyperSpeed Mouse", SYMLINK+="input/by-id/btmouse"
  '';


  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
  ];

  boot.kernelModules = [
    "vfio"
    "vfio_pci"
    "vfio_iommu_type1"
    "vfio_virqfd"
  ];

  # Replace with actual vendor:device IDs of the RX 6700 XT and its HDMI audio
  boot.extraModprobeConfig = ''
    options vfio-pci ids=1002:73df,1002:ab28
  '';

  # DO NOT blacklist amdgpu — you still need it for the RX580
  # services.xserver.videoDrivers = [ "amdgpu" ]; # Optional: use this to ensure host gets GPU driver

}
