{ config, lib, pkgs, ... }: {
  options = with lib; { git.enable = mkEnableOption "enable git"; };

  config = lib.mkIf config.git.enable {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "Ghibranalj";
          email = "24712554+Ghibranalj@users.noreply.github.com";
        };
        init.defaultBranch = "master";
        push.autoSetupRemote = true;
      };
    };
  };
}
