{ config, lib, pkgs, host, inputs, ... }:

with lib; {

  _module.args = { inherit inputs host; };

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
    ./libvirt.nix
    ./gaming.nix
    ./advcpmv.nix
    ./lightdm.nix
    ./gdm.nix
    ./wg-auto.nix
  ];

  environment.systemPackages = with pkgs; [
    inputs.witr.packages.${stdenv.hostPlatform.system}.default
    neovim # Install Neovim
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
    ntfs3g
    gh
    inetutils
    termshark
    pavucontrol
    bash-completion
    trash-cli
    comma
    strongswan

    # for secrets
    sops
    age

    (writeScriptBin "nix-cleanup" ''
      #!${pkgs.bash}/bin/bash
      sudo nix-collect-garbage -d 
      nix-collect-garbage -d
    '')

    (writeScriptBin "rm-ssh-host" ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail

      LINE="''${1:?Usage: $0 <line-number>}"
      FILE="$HOME/.ssh/known_hosts"

      if [[ ! -f "$FILE" ]]; then
        echo "known_hosts not found: $FILE" >&2
        exit 1
      fi

      sed -i "''${LINE}d" "$FILE"
    '')
  ];

  sysUsers.enable = mkDefault true;
  grub.enable = mkDefault true;
  services.printing.enable = mkDefault true;

  services.xserver.xkb = mkDefault {
    layout = "us";
    variant = "";
  };

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "id_ID.utf8";
    LC_IDENTIFICATION = "id_ID.utf8";
    LC_MEASUREMENT = "id_ID.utf8";
    LC_MONETARY = "id_ID.utf8";
    LC_NAME = "id_ID.utf8";
    LC_NUMERIC = "id_ID.utf8";
    LC_PAPER = "id_ID.utf8";
    LC_TELEPHONE = "id_ID.utf8";
    LC_TIME = "id_ID.utf8";
  };

  time.timeZone = mkDefault "Asia/Jakarta";

  networking.networkmanager.enable = mkDefault true;
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-l2tp
    networkmanager-sstp
    networkmanager-strongswan
    networkmanager-openvpn
  ];

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  environment = {
    variables = {
      NIX_HOSTNAME = host.hostName;
      NIXPKGS_ALLOW_UNFREE = 1;
    };
    shellAliases = {
      nix-rebuild =
        "sudo nixos-rebuild switch --flake /home/gibi/.nix#${host.hostName}";
      nix-update = "sudo nix-channel --update && nix-rebuild";
      nix-cleanup = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
    };
  };

  services.openssh = {
    enable = lib.mkDefault true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = lib.mkDefault true;
      AllowUsers =
        null; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = lib.mkDefault
        "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  gaming.enable = mkDefault false;

  virtualisation.docker = {
    enable = lib.mkDefault true;
    rootless = {
      enable = false;
      setSocketVariable = true;
    };
  };
  advcpmv.enable = lib.mkDefault true;

  boot.tmp.cleanOnBoot = lib.mkDefault true;
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    # Don't add hyprland portal here since programs.hyprland.enable adds it automatically
    extraPortals = with pkgs; [ ];
  };
}
