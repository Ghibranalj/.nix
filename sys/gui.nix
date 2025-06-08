{ config, lib, pkgs, ... }: {
  options = with lib; { gui.enable = mkEnableOption "enables gnome"; };

  config = lib.mkIf config.gui.enable {
    # Enable sound with pipewire.
    #

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
