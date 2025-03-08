{config, pkgs, ...}: {

  boot.loader = {
   efi = {
     efiSysMountPoint = "/boot/efi";
     canTouchEfiVariables = true;
   };
   grub = {
     enable = true;
     efiSupport = true;
     device = "nodev";  # Important for UEFI installation
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


  # Optional: Docker setup
  virtualisation.docker.enable = true;
  users.users.gibi.extraGroups = [ "docker" ];
}
