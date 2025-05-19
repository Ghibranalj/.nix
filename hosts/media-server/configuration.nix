{ config, lib, pkgs, nixarr, ... }:

{
  imports =
    [ ./nginx.nix ./orig-configuration.nix nixarr.nixosModules.default ];

  networking.hostName = "absolutely-legal-media-server";
  grub.enable = false;

  networking.firewall.enable = false;

  services.pipewire = { enable = false; };

  # For mount.cifs, required unless domain name resolution is not needed.
  fileSystems."/media" = {
    device = "10.0.16.50:/mnt/NAS/jelllyfin";
    fsType = "nfs";
    options = [ "rw" "hard" "intr" "vers=4.2" "sec=sys" ];

  };

  system.activationScripts.createMountPoint = {
    text = ''
      mkdir -p /media
    '';
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
        "rpc-host-whitelist" =
          "transmission.jellyfin.local,jellyfin.local,localhost,127.0.0.1";
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
    containers.filebrowser = {
      volumes = [
        "/media:/srv"
        "/var/media/.state/filebrowser/filebrowser.db:/database.db"
        "/var/media/.state/filebrowser/.filebrowser.json:/.filebrowser.json"
      ];
      extraOptions = [ "--user=1000:1000" ];
      ports = [ "8889:80" ];
      image = "filebrowser/filebrowser:latest";
    };
  };

  services.flaresolverr = {
    enable = true;
    port = 8191;
  };
}
