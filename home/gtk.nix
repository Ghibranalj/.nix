{ config, lib, pkgs, inputs, ... }: {
  options = with lib; { gtk-theme.enable = mkEnableOption "enable gtk theme"; };

  config = lib.mkIf config.gtk-theme.enable {

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
      theme = {
        name = lib.mkForce config.colorScheme.slug;
        package = lib.mkForce (let
          inherit (inputs.nix-colors.lib-contrib { inherit pkgs; })
            gtkThemeFromScheme;
        in gtkThemeFromScheme { scheme = config.colorScheme; });
      };
    };

    # Cursor Theme
    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk";
      style = {
        name = "adwaita-dark";
        package = pkgs.adwaita-qt;
      };
    };
  };
}
