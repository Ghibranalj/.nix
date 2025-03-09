{ config, pkgs, ... }:
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
  ];

  services.openssh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}

