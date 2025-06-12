{ config, lib, pkgs, prevpkgs, ... }: {
  options = with lib; { gui.enable = mkEnableOption "enables gnome"; };

  config = lib.mkIf config.gui.enable {

    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    services.udisks2.enable = true;

    hardware.graphics.enable = true;

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    environment.variables = { GUI = "TRUE"; };


    environment.systemPackages = with pkgs; [
      google-chrome
      vesktop
      pavucontrol
      spotify
      prevpkgs.vesktop
    ];

    fonts.packages = with pkgs;
      [
        noto-fonts-emoji
        fira-code-symbols
        source-code-pro
        #
      ] ++ builtins.filter lib.attrsets.isDerivation
      (builtins.attrValues pkgs.nerd-fonts);
  };
}
