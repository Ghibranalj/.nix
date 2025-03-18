{ config, lib, pkgs, host, ... }:
{
  options = {
    bash.enable = lib.mkEnableOption "enable bash";
  };

  config = lib.mkIf config.bash.enable {

    home.file.".bashrc".source = lib.mkForce ./files/.bashrc;
    programs.bash = {
        enable = true;
        profileExtra = ''
        . ${pkgs.git}/share/git/contrib/completion/git-prompt.sh
        '';
    };
  };
}
