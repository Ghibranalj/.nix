{ config, lib, pkgs, ... }:

{
  
  options = with lib; {
    xbindkeys.enable = mkEnableOption "enable xbindkeys";
  };


  config = lib.mkIf config.xbindkeys.enable {
    home.file.".config/xbindkeys/xbindkeysrc".source = ./files/xbindkeysrc;

    systemd.user.services.xbindkeys = {
        Unit = {
        Description = "xbindkeys";
        After = [ "graphical-session.target" "default.target" ];
        Wants = [ "graphical-session.target" ];
        };
        Service = {
        Type = "notify";
        ExecStart = "${pkgs.xbindkeys}/bin/xbindkeys -f ${config.home.homeDirectory}/.config/xbindkeys/xbindkeysrc --nodaemon";
        Environment = lib.mkForce [
            "PATH=/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${config.home.profileDirectory}/bin"
        ];
        Restart = "always";
        };
        Install = {
        WantedBy = [ "graphical-session.target" ];
        };
    };
  };
}
