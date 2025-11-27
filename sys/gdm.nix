{ config, lib, pkgs, inputs, ... }: {
  options = with lib; { gdm.enable = mkEnableOption "enable gdm"; };

  config = lib.mkIf config.gdm.enable {
    services.xserver.enable = true;

    services.displayManager.gdm = {
      enable = true;
      # 
    };

    services.displayManager.sddm.enable = lib.mkForce false;
    lightdm.enable = lib.mkForce false;

    programs.hyprland = {
      enable = lib.mkDefault (!config.gnome.enable);
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    };
  };
}
