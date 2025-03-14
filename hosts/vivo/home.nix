{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs.gnome; [
  ] ++ (with pkgs.gnomeExtensions; [
    caffeine
    blur-my-shell
    battery-time-2
    auto-power-profile
    hibernate-status-button
  ]);


  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions =
       [
         "blur-my-shell@aunetx" "caffeine@patapon.info" "batterytime@typeof.pw"
         "auto-power-profile@dmy3k.github.io" "hibernate-status@dromi"
       ];
    };
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = false;
    };
  };
}
