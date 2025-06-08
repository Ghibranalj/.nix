{ config, lib, pkgs, ... }:

{
  options = with lib; { libvirt.enable = mkEnableOption "enables libvirt"; };

  config = lib.mkIf config.libvirt.enable {
    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = [ "gibi" ];

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
        };
      };
    };

    virtualisation.spiceUSBRedirection.enable = true;
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;

    environment.systemPackages = with pkgs; [ OVMF ];
  };
}
