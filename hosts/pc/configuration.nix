{ config, lib, pkgs, ... }:

{

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];


  environment.systemPackages = with pkgs; [
    vlc
    discord-canary
  ];

  networking.hostName = "CreeprPC"; # Define your hostname.
  gui.enable = true;
  grub.enable = true;
  gnome.enable = false;
  lightdm.enable = true;
  programs.hyprland.enable = true;
  
  # Enable XDG desktop portal (needed for proper integration)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
    ];
  };
  # Optional: Set Hyprland as default session
  services.displayManager.defaultSession = "hyprland";

  dev.enable =true;
  winbox.enable =true;
  evdev-keymapper = {
  	enable = true;
	  device = "/dev/input/by-id/btkeyboard";
  };

  libvirt.enable = true;

  networking.firewall.enable = false;
  
  services.udev.extraRules = ''
    # Keyboard
    KERNEL=="event*", SUBSYSTEM=="input", ATTRS{name}=="AJAZZ K680T Keyboard", ACTION=="add", SYMLINK+="input/by-id/btkeyboard"

    KERNEL=="event*", SUBSYSTEM=="input", ATTRS{name}=="BT5.0 Mouse", ACTION=="add", SYMLINK+="input/by-id/btmouse"
  '';


  boot.resumeDevice="/dev/disk/by-uuid/6c8134b5-42d1-4259-bc3f-47bb585ad9f4";
  boot.kernelParams = [
    "hid.persist=0"             # Disable HID device persistence
    "btusb.disable_scofix=1"    # Fix Bluetooth HID latency
    "bluetooth.disable_ertm=1"  # Disable unreliable Bluetooth mode
    "amd_iommu=on"
    "iommu=pt"
    "resume=/dev/disk/by-uuid/6c8134b5-42d1-4259-bc3f-47bb585ad9f4"
  ];

  boot.kernelModules = [
    "vfio"
    "vfio_pci"
    "vfio_iommu_type1"
    "vfio_virqfd"
  ];

  boot.extraModprobeConfig = ''
    softdep drm pre: vfio vfio_pci
    options vfio-pci ids=1002:73df,1002:ab28
  '';

  services.persistent-evdev = {
    enable = true;
    devices = {
      persist-mouse0 = "btmouse";
    };

  };

  services.pipewire.extraConfig.pipewire."99-noflat" = {
    "context.properties" = {
      "flat-volumes" = false;
    };
  };

  # DO NOT blacklist amdgpu — you still need it for the RX580
  # services.xserver.videoDrivers = [ "amdgpu" ]; # Optional: use this to ensure host gets GPU driver

}
