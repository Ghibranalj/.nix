{ config, lib, pkgs, ... }:

{
  
  options = with lib; {
     docker.enable = mkEnableOption "enables gnome";
  };

  config = lib.mkIf config.docker.enable {
    virtualisation.docker.enable = true;
    users.users.gibi.extraGroups = [ "docker" ];
  };
}
