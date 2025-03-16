# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, lib ,inputs, ... }:

{

  # Bootloader.
  boot.loader = {
    efi = {
      efiSysMountPoint = "/boot";
      canTouchEfiVariables = true;
    };
    grub2-theme = {
      enable = true;
      theme = "stylish";
      footer = true;
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";  
      useOSProber = true;
    };
  };


  services.evdev-keymapper = {
    enable = true;
    settings = {
      Config = {
        toggle= false;
        device= "/dev/input/event0";
      };
      Keymap = {
        "RIGHTALT"="CAPSLOCK";
        CAPSLOCK = {
          "I"="UP";
          "K"="DOWN";
          "J"="LEFT";
          "L"="RIGHT";
          "B"="BACKSPACE";
          "F"="ESC";
          "N"="LEFTSHIFT+MINUS";
          "APOSTROPHE"="GRAVE";
        };
      };
    };
  };

  networking.hostName = "CreepRvivo"; # Define your hostname.
  # networking.wireless.enable = true; 

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  
 # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = with pkgs; [
    # baobab      # disk usage analyzer
    # eog         # image viewer
    epiphany    # web browser
    gedit       # text editor
    simple-scan # document scanner
    totem       # video player
    yelp        # help viewer
    evince      # document viewer
    file-roller # archive manager
    geary       # email client
    seahorse    # password manager

    # these should be self explanatory
    # gnome-logs gnome-clocks gnome-weather
    gnome-calendar gnome-characters  gnome-contacts
    gnome-font-viewer  gnome-maps gnome-music gnome-photos
    gnome-system-monitor  pkgs.gnome-connections
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gibi = {
    isNormalUser = true;
    description = "gibi";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  neovim
  git
  openssh
  gnome.gvfs
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 23 8080 443 1716 ];
  networking.firewall.allowedUDPPorts = [ 443 8080 1716 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.logind.extraConfig = ''
    HandlePowerKey=hibernate
    HandleLidSwitch=hibernate
  '';

  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=yes
    AllowHybridSleep=yes
    AllowSuspendThenHibernate=yes
  '';
  services.power-profiles-daemon.enable = false;
  # if gnome extension doenst work
  # services.tlp = {
  #       enable = true;
  #       settings = {
  #         CPU_SCALING_GOVERNOR_ON_AC = "performance";
  #         CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

  #         CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
  #         CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

  #         CPU_MIN_PERF_ON_AC = 0;
  #         CPU_MAX_PERF_ON_AC = 100;
  #         CPU_MIN_PERF_ON_BAT = 0;
  #         CPU_MAX_PERF_ON_BAT = 20;
  #         CPU_SCALING_MAX_FREQ_ON_BAT= 1000000000;

  #       #Optional helps save long term battery health
  #       START_CHARGE_THRESH_BAT0 = 40; # 40 and below it starts to charge
  #       STOP_CHARGE_THRESH_BAT0 = 90; # 80 and above it stops charging
  #       };
  # };

  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "schedutil";
        turbo = "never";
        scaling_max_freq = 1800000;
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };
}
