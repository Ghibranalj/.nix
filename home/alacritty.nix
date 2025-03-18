{ config, lib, pkgs, ... }:

{
  
  options = with lib; {
    alacritty.enable = mkEnableOption "enable alacritty";
  };

  config = lib.mkIf config.alacritty.enable {
    programs.alacritty = {
        enable = true;
        settings = lib.importTOML ./files/alacritty.toml;
    };
  };
}
