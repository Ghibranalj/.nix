{ config, lib, pkgs, ... }:

{
  options = with lib; {
    alacritty.enable = mkEnableOption "enable alacritty";
    alacritty.fontSize = mkOption {
      type = types.float;
      default = 9.5;
      description = "Alacritty font size";
    };
  };

  config = lib.mkIf config.alacritty.enable {
    programs.alacritty = {
        enable = true;
        settings = lib.importTOML ./files/alacritty.toml // {
          font.size = config.alacritty.fontSize;
        };
    };
  };
}
