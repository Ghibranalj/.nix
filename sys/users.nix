{ config, lib, pkgs, ... }:
{
  options = with lib; {
     sysUsers.enable = mkEnableOption "enables gnome";
  };

  config = lib.mkIf config.sysUsers.enable {
    users.users = {
        gibi = {
        isNormalUser = true;
        extraGroups = [ "networkmanager" "wheel" "audio" ];
        shell = pkgs.bash;
        hashedPassword = "$6$rounds=500000$TTyiR5QK1eGGRQc2$ZwEaJgoEBGw2ERXf3wPfqd8S28syb1WFFPlXNwt3.gas6iDWJK/zknZoCwJYxhExiImxvqz3.VORiQq685.jN1";
        linger = true;
        openssh.authorizedKeys.keys =  let
            keys = pkgs.fetchurl {
            url = "https://github.com/ghibranalj.keys";
            sha256 = "sha256-Dg/Pi4DRoMVygyH50fgPKHut6Z6bMG9egG7YUq4u8dY=";
            };
        in pkgs.lib.splitString "\n" (builtins.readFile keys);
        };
        root = {
        hashedPassword = "$6$rounds=500000$v3JKwQ2X5E1jLEf4$CVyW22XBpa/.Pk1L.blU3nHpELplifcFXjsU2IteYtZrPCsFJJbdO6mocQ.6rYr1110HaK3tU7twbX4qRS557/";
        };
    };
  };
}
