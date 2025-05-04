{ config, lib, pkgs, ... }:
let
  pcapScript = pkgs.writeScriptBin "gns3-pcap" ''
    #!${pkgs.bash}/bin/bash
    export PATH=${pkgs.lib.makeBinPath [
      pkgs.coreutils  # for mkdir, date, etc
      pkgs.gnused     # for sed
      pkgs.gnugrep    # for grep
      pkgs.curl       # for auth check
      pkgs.wget       # for downloading
      pkgs.termshark  # for pcap viewing
    ]}

    ${builtins.readFile ./files/gns3-pcap.sh}
    '';

  telnetScript = pkgs.writeScriptBin "gns3-telnet" ''
      url="$1"
      host=$(echo "$url" | sed -E 's|.*://([^:/?]+).*|\1|')
      port=$(echo "$url" | sed -E 's|.*:([0-9]+).*|\1|')
      name=$(echo "$url" | sed -n 's/.*[?&]name=\([^&]*\).*/\1/p' | sed 's/%20/ /g')

      exec ${pkgs.alacritty}/bin/alacritty \
      --title "Telnet: $name" \
      -e ${pkgs.inetutils}/bin/telnet "$host" "$port"
     '';
  gns3Handlers = pkgs.symlinkJoin {
    name = "gns3-handlers";
    paths = [ telnetScript pcapScript ];
  };
in
{
  options = with lib; {
    gns3-handlers.enable = mkEnableOption "gns3-handlers user";
  };

  config = lib.mkIf config.gns3-handlers.enable {

    home.packages = [
      gns3Handlers
    ];

    xdg.mimeApps = {
        enable = true;
        defaultApplications = {
        "x-scheme-handler/gns3+telnet" = "gns3-telnet.desktop";
        "x-scheme-handler/gns3+pcap" = "gns3-pcap.desktop";
        };
    };

    xdg.configFile."mimeapps.list".enable = false;
    xdg.dataFile."applications/mimeapps.list".force = true;

    xdg.desktopEntries.gns3-telnet = {
        name = "GNS3 Telnet";
        exec = "${telnetScript}/bin/gns3-telnet %u";
        mimeType = [ "x-scheme-handler/gns3+telnet" ];
        type = "Application";
        # terminal = true;
        categories = [ "Network" ];
    };

    xdg.desktopEntries.gns3-pcap = {
        name = "GNS3 PCAP Stream";
        exec = "${pkgs.alacritty}/bin/alacritty -e ${pcapScript}/bin/gns3-pcap %u";
        mimeType = [ "x-scheme-handler/gns3+pcap" ];
        type = "Application";
        categories = [ "Network" ];
    };
  };
}
