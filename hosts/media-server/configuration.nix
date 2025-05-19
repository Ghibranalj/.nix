{ config, lib, pkgs, nixarr, ... }:

{
  imports = [ 
    ./nginx.nix
    ./orig-configuration.nix
    nixarr.nixosModules.default
  ];

  networking.hostName = "absolutely-legal-media-server";
  grub.enable = false;

  networking.firewall.enable = false;

  services.pipewire = { enable = false; };

  # For mount.cifs, required unless domain name resolution is not needed.
  fileSystems."/mnt/media" = {
    device = "10.0.16.50:/mnt/NAS/jelllyfin";
    fsType = "nfs";
    options = [ "defaults" "vers=4" ];
  };
  # optional, but ensures rpc-statsd is running for on demand mounting
  boot.supportedFilesystems = [ "nfs" ];

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
      extraAllowedIps = [ "10.0.*" ];
      extraSettings = {
        "rpc-host-whitelist-enabled" = true;
        "rpc-host-whitelist" = "transmission.jellyfin.local,jellyfin.local,localhost,127.0.0.1";
      };

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

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers = {
    containers.unmanic = {
      volumes = [
        "/var/media/.state/unmanic/config:/config"
        #"/media/arr/unmanic/library:/library"
        "/var/media/.state/unmanic/tmp:/tmp/unmanic"
        "/media:/library"
      ];
      environment = {
        PUID = "1000";
        PGID = "1000";
      };
      ports = [ "127.0.0.1:8889:8888" ];
      image = "josh5/unmanic:latest";
    };
  };

  services.flaresolverr = {
    enable = true;
    port = 8191;
  };
}
