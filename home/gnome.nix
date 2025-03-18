{ config, lib, pkgs, ... }:

{
  options = with lib; {
    gnome.enable = mkEnableOption "enable gnome user";
  };

  config = lib.mkIf config.gnome.enable {
    home.packages = with pkgs; [
    ] ++ (with pkgs.gnomeExtensions; [
        caffeine
        blur-my-shell
        battery-time-2
        hibernate-status-button
        gsconnect
    ]);

    dconf.settings = with lib.hm.gvariant; {
        "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
            "blur-my-shell@aunetx" "caffeine@patapon.info" "batterytime@typeof.pw"
            "hibernate-status@dromi" "gsconnect@andyholmes.github.io"
        ];
        };
        "org/gnome/shell/extensions/blur-my-shell/panel" = {
        blur = false;
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        ];
        help = [];
        };
        # Define each custom keybinding under its full path
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Control><Alt>t";
        command = "alacritty";
        name = "terminal";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        binding = "<Control><Alt>Return";
        command = "emacsclient -c";
        name = "emacs";
        };
        "org/gnome/desktop/background" = {
        color-shading-type="solid";
        picture-options="zoom";
        picture-uri="file://${./files/background.png}";
        picture-uri-dark="file://${./files/background.png}";
        primary-color="#FFCB6B";
        };
        "org/gnome/desktop/peripherals/mouse" = {
        accel-profile="flat";
        natural-scroll=false;
        speed=-0.37593984962406013;
        };
    };
  };
}
