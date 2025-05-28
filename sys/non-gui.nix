{ config, lib, pkgs, ... }: {
  config = lib.mkIf (!config.gui.enable) {
    boot.plymouth.enable = false;
    services.xserver.enable = false;
    services.pulseaudio.enable = false;
  };
}
