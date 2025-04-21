{ config, lib, pkgs, host, inputs, ... }:

with lib;
{
  _module.args = {
    inherit inputs host;
  };

  imports = [
    ./gnome.nix
    ./grub.nix
    ./users.nix
    ./powerconf.nix
    ./gui.nix
    ./non-gui.nix
    ./evdev-keymapper.nix
    ./winbox.nix
    ./dev.nix
  ];

  environment.systemPackages = with pkgs; [
    neovim  # Install Neovim
    git
    wget
    curl
    openssh
    stow
    emacs30
    btop
    fd
    fzf
    coreutils
    ripgrep
    killall
    eza
  ];

  sysUsers.enable = mkDefault true;
  grub.enable = mkDefault true;
  services.printing.enable = mkDefault true;

  services.xserver.xkb = mkDefault {
    layout = "us";
    variant = "";
  };
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = mkDefault "Asia/Jakarta";
  networking.networkmanager.enable = mkDefault true;


  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}"];
  environment.variables = {
      NIX_HOSTNAME = host.hostName;
      NIXPKGS_ALLOW_UNFREE = 1;
  }; 

  environment.shellAliases = {
      nix-rebuild="sudo nixos-rebuild switch --flake /home/gibi/.nix#${host.hostName}";
      nix-update="sudo nix-channel --update && nix-rebuild";
      nix-cleanup="sudo nix-collect-garbage -d";
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
