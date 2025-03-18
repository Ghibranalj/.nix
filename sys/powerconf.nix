{ config, lib, pkgs, ... }:
{
  options = with lib; {
    powerconf.enable = mkEnableOption "enables power configurations";
    powerconf.saver = {
      enable = mkEnableOption "enable power saver";
      batteryGovernor = mkOption {
        type = types.string;
        default = "schedutil";
      };
      chargerGovernor = mkOption {
        type = types.str;
        default = "performance";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.powerconf.enable {
      services.logind.extraConfig = ''
        HandlePowerKey=hibernate
        HandleLidSwitch=hibernate
      '';
      systemd.sleep.extraConfig = ''
        AllowSuspend=yes
        AllowHibernation=yes
        AllowHybridSleep=yes
        AllowSuspendThenHibernate=yes
      '';
    })
    (lib.mkIf (config.powerconf.enable && config.powerconf.saver.enable) {
      services.power-profiles-daemon.enable = false;
      services.tlp.enable = false;
      services.auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
            governor = config.powerconf.saver.batteryGovernor;
            turbo = "never";
          };
          charger = {
            governor = config.powerconf.saver.chargerGovernor;
            turbo = "auto";
          };
        };
      };
    })
  ];
}
