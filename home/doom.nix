{ config, lib, pkgs, ... }:
{
  options = with lib; {
    doom.enable = mkEnableOption "enable doom emacs";
    doom.mode = mkOption {
      type = types.enum ["gui" "term"];
      default = "term";
    };
  };
  
  config = lib.mkIf config.doom.enable {
    programs.doom-emacs = {
        enable = true;
        doomDir = ./files/doom;
        provideEmacs = true;
    };

    systemd.user.services.emacs = let
        isGui = config.doom.mode == "gui";
        emacsServer = if isGui then "server" else "term";
        wantedBy = if isGui then "graphical-session" else "default";
        in {
        Unit = {
            Description = "Emacs text editor";
            Documentation = [ "info:emacs" "man:emacs(1)" "https://gnu.org/software/emacs/" ];
            After = lib.mkIf isGui [ "graphical-session.target" "default.target" ];
            Wants = lib.mkIf isGui [ "graphical-session.target" ];
        };
        Service = {
            Type = "notify";
            ExecStart = "${config.home.profileDirectory}/bin/emacs --fg-daemon=${emacsServer}";
            ExecStop = "${pkgs.emacs}/bin/emacsclient -s ${emacsServer} --eval '(kill-emacs)'";
            Environment = lib.mkForce [
            "PATH=/run/wrappers/bin:/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${config.home.profileDirectory}/bin:/run/"
            ];
            Restart = "always";
        };
        Install = {
            WantedBy = [ "${wantedBy}.target" ];
        };
    };
  };
}
