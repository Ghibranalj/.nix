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
  ];

  environment.systemPackages = with pkgs; [
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

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  environment.variables = {
    NIX_HOSTNAME = host.hostName;
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  environment.shellAliases = {
    nix-rebuild =
      "sudo nixos-rebuild switch --flake /home/gibi/.nix#${host.hostName}";
    nix-update = "sudo nix-channel --update && nix-rebuild";
    nix-cleanup = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
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
  system.stateVersion = "25.05"; # Did you read the comment?
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
}
