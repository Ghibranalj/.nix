{config, pkgs, ...}: {

 grub.enable = true;
 grub.efiMountPoint = "/boot/efi";
  # Disable all graphical components
 
  networking = {
    hostName = "nix-server";
    networkmanager.enable = true;
    firewall.enable = false;
  };

 docker.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      ClientAliveInterval = 300;    # 5 minutes
      ClientAliveCountMax = 36;     # 36 attempts
    };
  };
}
