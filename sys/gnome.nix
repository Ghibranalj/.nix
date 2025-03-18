{ config, lib, pkgs, ... }:
{

  options = with lib; {
     gnome.enable = mkEnableOption "enables gnome";
  };

  config = lib.mkIf config.gnome.enable {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    environment.gnome.excludePackages = with pkgs; [
        # baobab      # disk usage analyzer
        # eog         # image viewer
        epiphany    # web browser
        gedit       # text editor
        simple-scan # document scanner
        totem       # video player
        yelp        # help viewer
        evince      # document viewer
        file-roller # archive manager
        geary       # email client
        seahorse    # password manager

        # these should be self explanatory
        # gnome-logs gnome-clocks gnome-weather
        gnome-calendar gnome-characters  gnome-contacts
        gnome-font-viewer  gnome-maps gnome-music gnome-photos
        gnome-system-monitor  pkgs.gnome-connections
    ];

    services.gnome.gnome-keyring.enable = true;
  };
}
