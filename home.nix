{ config, pkgs, lib, nix-doom-emacs-unstraightened, ...} :{

  imports = [ nix-doom-emacs-unstraightened.hmModule ];

  home.username = "gibi";
  home.homeDirectory = "/home/gibi";
  home.stateVersion = "24.11";

  home.file.".bashrc".source = lib.mkForce (
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.nix/home/.bashrc"
  );

  programs.bash = {
   enable = true;
   initExtra = ''
      # Source system-wide bashrc
      if [ -f /etc/bashrc ]; then
        source /etc/bashrc
      fi

      # Source user-specific bashrc
      if [ -f ~/.bashrc ]; then
        source ~/.bashrc
      fi
    '';
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


#  home.file.".config/doom".source =  lib.mkForce (
#    config.lib.file.mkOutOfStoreSymlink
#      "${config.home.homeDirectory}/.nix/home/doom"
#  );

  programs.doom-emacs = {
    enable = true;
    doomDir = ./home/doom;
  };
}
