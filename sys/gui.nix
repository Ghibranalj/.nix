{ config, lib, pkgs, prevpkgs, ... }: {
  options = with lib; { gui.enable = mkEnableOption "enables gnome"; };

  config = lib.mkIf config.gui.enable {

    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    services.udisks2.enable = true;

    hardware.graphics.enable = true;
    programs.noisetorch.enable = true;
    programs.localsend.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    security.rtkit.enable = true;
    environment.variables = { GUI = "TRUE"; };

    environment.systemPackages = with pkgs; [
      google-chrome
      pavucontrol
      spotify
      networkmanagerapplet
      discord
      emacs-all-the-icons-fonts
      gedit
    ];

    fonts.packages = with pkgs;
      [ noto-fonts-emoji fira-code-symbols source-code-pro ]
      ++ builtins.filter lib.attrsets.isDerivation
      (builtins.attrValues pkgs.nerd-fonts);
  };
}
