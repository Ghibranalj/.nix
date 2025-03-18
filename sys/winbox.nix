{ config, lib, pkgs, ... }:
let
    winbox4_override = pkgs.winbox4.overrideAttrs (old: {
    postInstall = ''
        install -Dm644 "assets/img/winbox.png" "$out/share/pixmaps/winbox4.png"
    '';
    desktopItems = old.desktopItems or [] ++ [
        (pkgs.makeDesktopItem {
        name = "winbox4";
        desktopName = "Winbox 4";
        comment = "GUI administration for Mikrotik RouterOS";
        exec = "WinBox";
        icon = "winbox4";
        categories = [ "Utility" ];
        })
    ];
    });
in
{
  options = with lib; {
     winbox.enable = mkEnableOption "enables gnome";
  };
 
  config = lib.mkIf config.winbox.enable {
    environment.systemPackages = with pkgs; [
      winbox3
      winbox4_override
    ];
  };
}
