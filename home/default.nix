{ config, lib, pkgs, inputs, host, ... }:

with lib; {
  _module.args = { inherit inputs host; };

  imports = [
    ./alacritty.nix
    ./bash.nix
    ./doom.nix
    ./git.nix
    ./gtk.nix
    ./neovim.nix
    ./rofi.nix
    ./hyprland
    ./xbindkeys.nix
    ./gnome.nix
    ./gns3.nix
    ./easyeffect.nix
  ];

  home = {
    username = "gibi";
    homeDirectory = "/home/gibi";
    stateVersion = "25.11";
    sessionVariables = { };
  };

  bash.enable = mkDefault true;
  git.enable = mkDefault true;
  neovim.enable = mkDefault true;
  doom.enable = mkDefault true;

  gns3-handlers.enable = mkDefault true;

}
