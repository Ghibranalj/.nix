{ config, lib, pkgs, ... }: {
  options = with lib; {
    doom.enable = mkEnableOption "enable doom emacs";
    doom.mode = mkOption {
      type = types.enum [ "gui" "term" ];
      default = "term";
    };
    doom.fontSize = {
      normal = mkOption {
        type = types.int;
        default = 16;
      };
      big = mkOption {
        type = types.int;
        default = 20;
      };

    };
  };

  config = lib.mkIf config.doom.enable {
    programs.doom-emacs = {
      extraBinPackages = with pkgs; [ git fd ripgrep tree-sitter ];
      enable = true;
      doomDir = ./files/doom;
      provideEmacs = true;
      extraPackages = epkgs: [ epkgs.treesit-grammars.with-all-grammars epkgs.inheritenv ];
      experimentalFetchTree = false;
    };

    xdg.configFile."doomfont/font.el".text = ''
      (setq
          doom-font (font-spec
                      :family "Source Code Pro"
                      :size ${toString config.doom.fontSize.normal})
          doom-variable-pitch-font (font-spec
                                  :family "Source Code Pro"
                                  :size ${toString config.doom.fontSize.normal})
          doom-big-font (font-spec
                          :family "Source Code Pro"
                          :size ${toString config.doom.fontSize.big}))
    '';

    systemd.user.services.emacs = let
      isGui = config.doom.mode == "gui";
      emacsServer = if isGui then "server" else "term";
      wantedBy = if isGui then "graphical-session" else "default";
      # Create a wrapper script
      emacs-wrapper = pkgs.writeShellScriptBin "emacs-wrapper" ''
        #!/bin/bash

        # Source bashrc if it exists
        if [ -f "$HOME/.bashrc" ]; then
            source "$HOME/.bashrc"
            else
            echo "No bashrc"
        fi

        # Execute emacs with the passed arguments
        exec ${config.home.profileDirectory}/bin/emacs "$@"
      '';
    in {
      Unit = {
        Description = "Emacs text editor";
        Documentation =
          [ "info:emacs" "man:emacs(1)" "https://gnu.org/software/emacs/" ];
        After = lib.mkIf isGui [ "graphical-session.target" "default.target" ];
        Wants = lib.mkIf isGui [ "graphical-session.target" ];
      };
      Service = {
        Type = "notify";
        ExecStart =
          "${emacs-wrapper}/bin/emacs-wrapper --fg-daemon=${emacsServer}";
        ExecStop =
          "${pkgs.emacs}/bin/emacsclient -s ${emacsServer} --eval '(kill-emacs)'";
        Environment = lib.mkForce [
          "PATH=/run/wrappers/bin:/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${config.home.profileDirectory}/bin:/run/"
        ];
        Restart = "always";
      };
      Install = { WantedBy = [ "${wantedBy}.target" ]; };
    };

  };
}
