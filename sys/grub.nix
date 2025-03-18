{ config, lib, pkgs, ... }:

{
  options = with lib;{
     grub.enable = mkEnableOption "enables gnome";
     grub.efiMountPoint = mkOption {
       type = types.string;
       default = "/boot";
     };
  };

  config = lib.mkIf config.grub.enable {
    # Bootloader.
    boot.loader = {
        efi = {
            efiSysMountPoint = config.grub.efiMountPoint;
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
  };
}
