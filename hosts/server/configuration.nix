{config, pkgs, ...}: {

 boot.loader = {
   efi = {
     efiSysMountPoint = "/boot/efi";
     canTouchEfiVariables = true;
   };
   grub = {
     enable = true;
     efiSupport = true;
     device = "nodev";  
    };
  };

  # Disable all graphical components
 
  boot.plymouth.enable = false;
  services.xserver.enable = false;
  hardware.pulseaudio.enable = false;

  networking = {
    hostName = "nix-server";
    networkmanager.enable = true;
    firewall.enable = false;
  };

  time.timeZone = "Asia/Jakarta";
  
  virtualisation.docker.enable = true;
  users.users.gibi.extraGroups = [ "docker" ];

  services.openssh = {
    enable = true;
    settings = {
      ClientAliveInterval = 300;    # 5 minutes
      ClientAliveCountMax = 36;     # 36 attempts
    };
  };
}
