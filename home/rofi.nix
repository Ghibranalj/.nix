{ config, lib, ... }:

{
  options = with lib; {
    rofi.enable = mkEnableOption "enable rofi";
  };
  config = lib.mkIf config.rofi.enable {
    home.file.".config/rofi/config.rasi".source = ./files/config.rasi;
  };
}
