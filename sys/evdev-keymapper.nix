{ config, lib, pkgs, ... }:

{
  options = with lib; {
     evdev-keymapper.enable = mkEnableOption "enables evdev-keymapper";
     evdev-keymapper.device = mkOption {
       type = types.str;
       default = "/dev/input/event0";
     };
  };

  config = lib.mkIf config.evdev-keymapper.enable {
    services.evdev-keymapper = {
        enable = true;
        settings = {
            Config = {
                toggle = false;
                device = config.evdev-keymapper.device;
            };
            Keymap = {
                "RIGHTALT"="CAPSLOCK";
                CAPSLOCK = {
                    "I"="UP";
                    "K"="DOWN";
                    "J"="LEFT";
                    "L"="RIGHT";
                    "B"="BACKSPACE";
                    "F"="ESC";
                    "N"="LEFTSHIFT+MINUS";
                    "APOSTROPHE"="GRAVE";
                };
            };
        };
    };
  };
}
