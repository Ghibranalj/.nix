{ config, lib, pkgs, nixarr, ... }:

{
  imports = [ 
    ./nginx.nix
    nixarr.nixosModules.default
  ];

  grub.enable = true;
  networking.hostName = "absolutely-legal-media-server";

  networking.firewall.enable = false;

  services.pipewire = { enable = false; };

  # For mount.cifs, required unless domain name resolution is not needed.
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/media" = {
    device = "//10.0.16.50/jellyfin";
    fsType = "cifs";
    options = let
      automount_opts =
        "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in [
      "${automount_opts},credentials=${./smb_secret}"
    ]; # DONT BOTHER HACKING THESE. THIS IS LOCAL ONLY AND OTHER IPS ARE BLOCKED
  };

  nixarr = {
    enable = true;
    # These two values are also the default, but you can set them to whatever
    # else you want
    # WARNING: Do _not_ set them to `/home/user/whatever`, it will not work!
    mediaDir = "/media";
    stateDir = "/var/media/.state/nixarr";

    vpn = { enable = false; };

    jellyfin = {
      enable = true;
      # These options set up a nginx HTTPS reverse proxy, so you can access
      # Jellyfin on your domain with HTTPS
      expose.https = { enable = false; };
    };

    transmission = {
      enable = true;
      vpn.enable = false;
      peerPort = 50000; # Set this to the port forwarded by your VPN
    };

    # It is possible for this module to run the *Arrs through a VPN, but it
    # is generally not recommended, as it can cause rate-limiting issues.
    bazarr.enable = true;
    lidarr.enable = true;
    prowlarr.enable = true;
    radarr.enable = true;
    readarr.enable = true;
    sonarr.enable = true;
    jellyseerr.enable = true;
  };
}
