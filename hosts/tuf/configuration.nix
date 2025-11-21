{ config, pkgs, lib, inputs, upkgs, ... }: {

  gui.enable = true;
  grub.enable = true;
  gnome.enable = true;

  lightdm.enable = false;
  gdm.enable = true;

  powerconf.enable = true;
  powerconf.saver.enable = true;
  evdev-keymapper.enable = true;
  dev.enable = true;
  winbox.enable = true;
  libvirt.enable = true;

  networking.hostName = "CreeprTUF"; 

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

  services.teamviewer = {
    enable = true;
    package = upkgs.teamviewer;
  };

  networking.firewall.enable = false;

  environment.systemPackages = with pkgs; [
    vlc
    upkgs.teamviewer
    kdePackages.kdenlive
    wine-wayland
    wine
    ffmpeg
  ];

  programs.zoom-us.enable = true;

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-source-clone
      droidcam-obs
      obs-websocket
      ##
    ];
  };
}
