{ config, lib, pkgs, ... }:

{
  options = with lib; {
    rofi.enable = mkEnableOption "enable rofi";
  };
  config = lib.mkIf config.rofi.enable {
    programs.rofi = {
        enable = true;
        package = pkgs.rofi; # (if host.X11 then pkgs.rofi else pkgs.rofi-wayland);
        configPath = "";
        plugins = [
            pkgs.rofi-calc
            pkgs.rofi-emoji
        ];
    };
    home.file.".config/rofi/config.rasi".source = ./files/config.rasi;
  };
}
