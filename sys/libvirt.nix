{ config, lib, pkgs, ... }:

{
  options = with lib; {
     libvirt.enable = mkEnableOption "enables libvirt";
  };


  config = lib.mkIf config.libvirt.enable {
    programs.virt-manager.enable = true;

    users.groups.libvirtd.members = [ "gibi" ];

    virtualisation.libvirtd.enable = true;

    virtualisation.spiceUSBRedirection.enable = true;

    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;

  };
}
