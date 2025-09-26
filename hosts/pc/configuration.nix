{ config, lib, pkgs, ... }: {

  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  environment.systemPackages = with pkgs; [
    vlc
    discord-canary
    handbrake
    #
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
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  };
  # Optional: Set Hyprland as default session
  services.displayManager.defaultSession = "hyprland";

  dev.enable = true;
  winbox.enable = true;
  evdev-keymapper = {
    enable = true;
    device = "/dev/input/by-id/btkeyboard";
  };

  libvirt.enable = true;

  networking.firewall.enable = false;

  services.udev.extraRules = ''
    # Keyboard
    KERNEL=="event*", SUBSYSTEM=="input", ATTRS{name}=="AK680 MAX-1 Keyboard", ACTION=="add", SYMLINK+="input/by-id/btkeyboard"

    KERNEL=="event*", SUBSYSTEM=="input", ATTRS{name}=="BT5.0 Mouse", ACTION=="add", SYMLINK+="input/by-id/btmouse"
  '';

  boot.resumeDevice = "/dev/disk/by-uuid/6c8134b5-42d1-4259-bc3f-47bb585ad9f4";
  boot.kernelParams = [
    "hid.persist=0" # Disable HID device persistence
    "btusb.disable_scofix=1" # Fix Bluetooth HID latency
    "bluetooth.disable_ertm=1" # Disable unreliable Bluetooth mode
    "amd_iommu=on"
    "iommu=pt"
    "resume=/dev/disk/by-uuid/6c8134b5-42d1-4259-bc3f-47bb585ad9f4"
    "amdgpu.gpu_recovery=1" # Enable GPU recovery
  ];

  boot.kernelModules = [ "vfio" "vfio_pci" "vfio_iommu_type1" "vfio_virqfd" ];

  boot.extraModprobeConfig = ''
    # Bind only the RX 6700 XT to VFIO
    options vfio-pci ids=1002:73df,1002:ab28 disable_vga=1
  '';

  services.persistent-evdev = {
    enable = true;
    devices = { persist-mouse0 = "btmouse"; };
  };

  systemd.services.persistent-evdev = {
    wants = [ "bluetooth.service" ];
    after = [ "bluetooth.service" ];
  };

  services.pipewire.extraConfig.pipewire."99-noflat" = {
    "context.properties" = { "flat-volumes" = false; };
  };

  # Use amdgpu driver for R9 380
  services.xserver.videoDrivers = [ "amdgpu" ];

}
