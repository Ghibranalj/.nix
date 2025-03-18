{ config, lib, pkgs, ... }:
{
  options = with lib;{
    git.enable = mkEnableOption "enable git";
  };

  config = lib.mkIf config.git.enable {
    programs.git = {
        enable = true;
        userName = "Ghibranalj";
        userEmail = "24712554+Ghibranalj@users.noreply.github.com";
        extraConfig = {
        init.defaultBranch = "master";
        };
    };
  };
}
