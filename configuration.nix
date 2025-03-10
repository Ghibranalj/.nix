{ config, pkgs, dev, ... }:
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
          sha256 = "09nfj3bmyjx23z4kcy1w3ah1vpkvm0lgwp12nzzbb51a6x4bnfy3";
        };
      in pkgs.lib.splitString "\n" (builtins.readFile keys);
    };
    root = {
      hashedPassword = "$6$rounds=500000$v3JKwQ2X5E1jLEf4$CVyW22XBpa/.Pk1L.blU3nHpELplifcFXjsU2IteYtZrPCsFJJbdO6mocQ.6rYr1110HaK3tU7twbX4qRS557/";
    };
  };

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
  ] ++ (if  dev then [
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
    nil
    eslint
    yaml-language-server
    jdt-language-server
    lua-language-server
    typescript-language-server
    gocode-gomod
    ] else []) ;

  services.openssh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}

