{ config, pkgs, lib, nix-doom-emacs-unstraightened, gui, ... }:

{
  imports = [ nix-doom-emacs-unstraightened.hmModule ];

  home.username = "gibi";
  home.homeDirectory = "/home/gibi";
  home.stateVersion = "24.11";

  home.file.".bashrc".source = lib.mkForce (
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.nix/home/.bashrc"
  );

  home.sessionVariables = {
    GUI = if gui then "TRUE" else "FALSE";
  }; 

  programs.bash = {
    enable = true;
  };

  home.file.".config/git-prompt.sh".source = "${pkgs.git}/share/git/contrib/completion/git-prompt.sh";
  programs.git = {
    enable = true;
    userName = "Ghibranalj";
    userEmail = "24712554+Ghibranalj@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "master";
    };
  };

  programs.doom-emacs = {
    enable = true;
    doomDir = ./home/doom;
    provideEmacs = true;
  };

  systemd.user.services = {
    emacs = lib.mkIf gui {
      Unit = {
        Description = "Emacs text editor";
        Documentation = [ "info:emacs" "man:emacs(1)" "https://gnu.org/software/emacs/" ];
      };
      Service = {
        Type = "notify";
        ExecStart = "${config.home.profileDirectory}/bin/emacs --fg-daemon";
        ExecStop = "${pkgs.emacs}/bin/emacsclient --eval '(kill-emacs)'";
        Environment = lib.mkForce [
          "PATH=/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${config.home.profileDirectory}/bin"
        ];
        Restart = "always";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    emacs-term = lib.mkIf (!gui) {
      Unit = {
        Description = "Emacs text editor";
        Documentation = [ "info:emacs" "man:emacs(1)" "https://gnu.org/software/emacs/" ];
      };
      Service = {
        Type = "notify";
        ExecStart = "${config.home.profileDirectory}/bin/emacs --fg-daemon=term";
        ExecStop = "${pkgs.emacs}/bin/emacsclient --eval -s term '(kill-emacs)'";
        Environment = "PATH=/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${config.home.profileDirectory}/bin";
        PassEnvironment = "";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      material-nvim
    ]; 
    extraLuaConfig = ''
      require('material').setup()
      vim.g.material_style = "darker"
      vim.cmd 'colorscheme material'
      vim.cmd 'set number relativenumber'
    '';
  };
}
