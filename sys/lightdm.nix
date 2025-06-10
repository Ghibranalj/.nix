{ config, lib, pkgs, ... }:

{

  options = with lib; { lightdm.enable = mkEnableOption "enable lightdm"; };

  config = lib.mkIf config.lightdm.enable {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    programs.hyprland.enable = true;
  };
}
