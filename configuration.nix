{ config, pkgs, lib, inputs, host, ... }:
{
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };
  

  users.users = {
    gibi = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.bash;
      hashedPassword = "$6$rounds=500000$TTyiR5QK1eGGRQc2$ZwEaJgoEBGw2ERXf3wPfqd8S28syb1WFFPlXNwt3.gas6iDWJK/zknZoCwJYxhExiImxvqz3.VORiQq685.jN1";
      linger = true;
      openssh.authorizedKeys.keys =  let
        keys = pkgs.fetchurl {
          url = "https://github.com/ghibranalj.keys";
          sha256 = "0pk2a1fmnr17amy9sq8an3y2afxj15djv3iymi4rp1mmyrmgddvm";
        };
      in pkgs.lib.splitString "\n" (builtins.readFile keys);
    };
    root = {
      hashedPassword = "$6$rounds=500000$v3JKwQ2X5E1jLEf4$CVyW22XBpa/.Pk1L.blU3nHpELplifcFXjsU2IteYtZrPCsFJJbdO6mocQ.6rYr1110HaK3tU7twbX4qRS557/";
    };
  };

  fonts.packages = with pkgs; (if host.isGui then [
    nerdfonts
    noto-fonts-emoji
    fira-code-symbols
  ] else []);

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
  ]
  ++(if host.isGui then [
    google-chrome
    alacritty
    xbindkeys
    vesktop
    winbox
  ] ++ ( let
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
  in [winbox4_override])
     else [])
  ++(if host.dev then [
    ## Compilers
    go
    gcc
    gnumake
    rustup
    python3
    texliveSmall
    jdk
    nodejs
    pnpm
    zig
    ## LSP
    gopls
    ccls
    nixd
    eslint
    yaml-language-server
    jdt-language-server
    lua-language-server
    typescript-language-server
    gocode-gomod
    ] else [])
  ++ (if host.X11 then [
     rofi
    ] # wayland
    else []);

  #winbox4 override
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}"];

  environment.variables = {
      NIX_HOSTNAME = host.hostName;
  }; 

  services.openssh.enable = lib.mkDefault true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}

