{ config, lib, pkgs, ... }:

with lib; {
  options = { gaming.enable = mkEnableOption "enables gaming"; };

  config = mkIf config.gaming.enable {
    nixpkgs.config.multiarchSupport = true;


    hardware.graphics.enable = true;

    environment.systemPackages = with pkgs; [
      lutris
      steam-run
      protonup
      mangohud
    ];

    programs = {
      gamemode = { enable = true; };
      steam = { enable = true; };
    };
  };
}
