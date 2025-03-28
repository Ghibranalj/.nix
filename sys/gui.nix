{ config, lib, pkgs, ... }:

{
  
  options = with lib; {
     gui.enable = mkEnableOption "enables gnome";
  };

  config = if config.gui.enable then {
    # Enable sound with pipewire.
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
    };
    environment.variables = {
      GUI = "TRUE";
    }; 

    environment.systemPackages = with pkgs; [
      google-chrome
      vesktop
    ];

    fonts.packages = with pkgs; [
      nerdfonts
      noto-fonts-emoji
      fira-code-symbols
    ];
  } else {
    boot.plymouth.enable = false;
    services.xserver.enable = false;
    hardware.pulseaudio.enable = false;
  };
}
