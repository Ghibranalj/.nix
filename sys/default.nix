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
    ./libvirt.nix
    ./gaming.nix
    ./advcpmv.nix
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
    ntfs3g
    gh
<<<<<<< HEAD
    inetutils
    termshark
=======
    pavucontrol
    bash-completion
>>>>>>> d015917 (feat: working PC)
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

<<<<<<< HEAD
  services.openssh = {
    enable = lib.mkDefault true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = lib.mkDefault true;
      AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = lib.mkDefault "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
=======
  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
>>>>>>> d015917 (feat: working PC)
  };
 
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

<<<<<<< HEAD
  gaming.enable = mkDefault false;
=======

  virtualisation.docker = {
    enable = lib.mkDefault true;
    rootless = {
      enable = false;
      setSocketVariable = true;
    };
  };
  advcpmv.enable = lib.mkDefault true;
>>>>>>> d015917 (feat: working PC)
}
