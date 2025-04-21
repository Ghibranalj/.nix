{ config, lib, pkgs, ... }:

{
  gui.enable = true;
  grub.enable = true;
  gnome.enable = true;
  dev.enable =true;
  winbox.enable =true;

  environment.systemPackages = with pkgs; [
    libvirt
  ];

  networking.firewall.enable = false;
  
  services.udev.extraRules = ''
    # Keyboard
    KERNEL=="event[0-9]|event[0-9][0-9]", SUBSYSTEM=="input", ATTRS{name}=="AJAZZ K680T Keyboard", ACTION=="add", SYMLINK+="input/by-id/btkeyboard"
    KERNEL=="event[0-9]|event[0-9][0-9]", SUBSYSTEM=="input", ATTRS{name}=="AJAZZ K680T Keyboard", ACTION=="remove", SYMLINK-="input/by-id/btkeyboard"

    # Mouse
    KERNEL=="event[0-9]|event[0-9][0-9]", SUBSYSTEM=="input", ATTRS{name}=="Basilisk X HyperSpeed Mouse", ACTION=="add", SYMLINK+="input/by-id/btmouse"
    KERNEL=="event[0-9]|event[0-9][0-9]", SUBSYSTEM=="input", ATTRS{name}=="Basilisk X HyperSpeed Mouse", ACTION=="remove", SYMLINK-="input/by-id/btmouse"
  '';

}
