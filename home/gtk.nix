{ config, lib, pkgs, ... }: {
  options = with lib; { gtk-theme.enable = mkEnableOption "enable gtk theme"; };

  config = lib.mkIf config.gtk-theme.enable {

    stylix = {
      enable = true;
      image = ./files/background.png;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/material-darker.yaml";
      polarity = "dark";
      targets = {
        alacritty.enable = false;
        emacs.enable = false;
        rofi.enable = false;
        hyprland.enable = false;
        neovim.enable = false;
        swaync.enable = false;
      };
      fonts = {
        serif = {
          package = pkgs.source-serif-pro;
          name = "Source Serif Pro";
        };

        sansSerif = {
          package = pkgs.source-sans-pro;
          name = "Source Sans Pro";
        };

        monospace = {
          package = pkgs.source-code-pro;
          name = "Source Code Pro";
        };

        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
      };
    };

    gtk = {
      enable = true;
      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
      cursorTheme = {
        name = "Adwaita-dark";
        package = pkgs.adwaita-icon-theme;
        size = 24;
      };
      gtk3.extraConfig = { gtk-application-prefer-dark-theme = 1; };

      gtk4.extraConfig = { gtk-application-prefer-dark-theme = 1; };
    };

    # Cursor Theme
    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    # Handle GTK theme preferences through dconf
    dconf.settings = {
      "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };
    };
  };
}
