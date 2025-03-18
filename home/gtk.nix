{ config, lib, pkgs, inputs, ... }:
{
  options = with lib; {
    gtk-theme.enable = mkEnableOption "enable gtk theme";
  };

  config = lib.mkIf config.gtk-theme.enable {

    gtk = {
        enable = true;
        theme = {
        name = config.colorScheme.slug;
        package = 
        let
            inherit
            (inputs.nix-colors.lib-contrib {inherit pkgs;})
            gtkThemeFromScheme
            ;
        in
            gtkThemeFromScheme {scheme = config.colorScheme;};
        };
    };
  };
}
