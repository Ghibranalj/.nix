{ config, lib, pkgs, ... }:
{
  options = with lib; {
    doom.enable = mkEnableOption "enable doom emacs";
    doom.mode = mkOption {
      type = types.enum ["gui" "term"];
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
        extraBinPackages = with pkgs;[
            git fd ripgrep tree-sitter
        ];
        enable = true;
        doomDir = ./files/doom;
        provideEmacs = true;
        extraPackages = epkgs: [ epkgs.treesit-grammars.with-all-grammars ];
    };

    xdg.configFile."doomfont/font.el".text  = ''
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


    # snippets
    home.activation.copyDoomSnippets = lib.hm.dag.entryAfter ["writeBoundary"] ''
        # Create the snippets directory
        OUT=${config.home.homeDirectory}/.config/doom-snippets

        $DRY_RUN_CMD rm -rf $OUT
        $DRY_RUN_CMD mkdir -p $OUT

        # Copy snippets from your nix config
        $DRY_RUN_CMD cp -r ${./files/doom-snippets}/* $OUT

        $DRY_RUN_CMD chmod -R +wr $OUT

        $DRY_RUN_CMD ${pkgs.emacs}/bin/emacs --batch \
           --eval "(require 'package)" \
           --eval "(package-initialize)" \
           --eval "(unless (package-installed-p 'yasnippet) 
                   (add-to-list 'package-archives '(\"melpa\" . \"https://melpa.org/packages/\") t)
                   (package-refresh-contents) 
                   (package-install 'yasnippet))" \
           --eval "(require 'yasnippet)" \
           --eval "(yas-compile-directory \"$OUT\")"

        echo "Doom snippets copied to $OUT"
    '';
    # home.packages = [
    #     (pkgs.writeShellScriptBin "setup-doom-snippets" ''
    #     # Create writable snippets directory
    #     OUT=${config.home.homeDirectory}/.config/doom-snippets
    #     mkdir -p $OUT

    #     # Copy snippets from Nix profile
    #     cp -r ${./files/doom-snippets}/* $OUT

    #     # Force compilation

    #     '')
    # ];
  };
}
