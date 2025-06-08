{ config, lib, pkgs, ... }:

{
  options = with lib; {
     libvirt.enable = mkEnableOption "enables libvirt";
  };


  config = lib.mkIf config.libvirt.enable {
    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = [ "gibi" ];
    virtualisation.spiceUSBRedirection.enable = true;
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;

    environment.systemPackages = with pkgs; [ 
      OVMF
    ];
    virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          ovmf.enable = true;  # Enable OVMF for UEFI support
          swtpm.enable = true;  # Optional: For TPM support (Windows 11, etc.)
        };
      };
  };
}
