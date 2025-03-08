{ config, pkgs, ...} :{

  home.username = "gibi";
  home.homeDirectory = "/home/gibi";
  home.stateVersion = "24.11";

  home.file.".bashrc".source= config.lib.file.mkOutOfStoreSymlink
     "${config.home.homeDirectory}/.nix/home/.bashrc";

  programs.git = {
    enable = true;
    userName = "Ghibranalj";
    userEmail = "24712554+Ghibranalj@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "master";
    };
  };
}
