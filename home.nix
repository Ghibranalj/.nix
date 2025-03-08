{ config, pkgs, lib, ...} :{

  home.username = "gibi";
  home.homeDirectory = "/home/gibi";
  home.stateVersion = "24.11";

  home.file.".bashrc".source = lib.mkForce (
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.nix/home/.bashrc"
  
  );

  home.file.".config/git-prompt.sh".source = "${pkgs.git}/share/git/contrib/completion/git-prompt.sh";


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

  programs.git = {
    enable = true;
    userName = "Ghibranalj";
    userEmail = "24712554+Ghibranalj@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "master";
    };
  };
}
