{ config, lib, pkgs, ... }:
let cfg = config.easyeffect;
in {
  options.easyeffect = with lib; {
    enable = mkEnableOption "enable easyeffects integration";
    # Name of preset file (without .json), e.g. "advanced-auto-gain"
    preset = mkOption {
      type = types.str;
      default = "advanced-auto-gain";
      description = "Name of the EasyEffects preset (without .json extension)";
    };
    inputOnly = mkOption {
      type = types.bool;
      default = false;
      description = "Whether or not to use only input";
    };
  };
  config = lib.mkIf cfg.enable {
    services.easyeffects = {
      enable = true;
      preset = if cfg.inputOnly then "noise-reduction" else cfg.preset;
      extraPresets = {
        "${cfg.preset}" = lib.mkIf (!cfg.inputOnly) {
          output =
            builtins.fromJSON (builtins.readFile ./files/${cfg.preset}.json);
        };
        "noise-reduction" = {
          input =
            builtins.fromJSON (builtins.readFile ./files/noise-reduction.json);
        };
      };
    };
  };
}
