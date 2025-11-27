{ config, lib, pkgs, ... }: {
  options = with lib; {
    powerconf.enable = mkEnableOption "enables power configurations";
    powerconf.saver = {
      enable = mkEnableOption "enable power saver";
      batteryGovernor = mkOption {
        type = types.str;
        default = "schedutil";
        description =
          "run cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors";
      };
      chargerGovernor = mkOption {
        type = types.str;
        default = "performance";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.powerconf.enable {
      services.logind.settings.Login = {
        HandlePowerKey = "hibernate";
        HandleLidSwitch = "hibernate";
      };
      systemd.sleep.extraConfig = ''
        AllowSuspend=yes
        AllowHibernation=yes
        AllowHybridSleep=yes
        AllowSuspendThenHibernate=yes
      '';
    })
    (lib.mkIf (config.powerconf.enable && config.powerconf.saver.enable) {
      services.power-profiles-daemon.enable = false;
      services.tlp = {
        enable = true;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = config.powerconf.saver.chargerGovernor;
          CPU_SCALING_GOVERNOR_ON_BAT = config.powerconf.saver.batteryGovernor;
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          CPU_BOOST_ON_AC = 1;
          CPU_BOOST_ON_BAT = 0;
          CPU_HWP_DYN_BOOST_ON_AC = 1;
          CPU_HWP_DYN_BOOST_ON_BAT = 0;
          PLATFORM_PROFILE_ON_AC = "performance";
          PLATFORM_PROFILE_ON_BAT = "low-power";
          USB_AUTOSUSPEND = 1;
          USB_EXCLUDE_AUDIO = 1;
          USB_EXCLUDE_BTUSB = 1;
          USB_EXCLUDE_PHONE = 1;
          WIFI_PWR_ON_AC = "off";
          WIFI_PWR_ON_BAT = "on";
          WOL_DISABLE = "Y";
          SOUND_POWER_SAVE_ON_AC = 0;
          SOUND_POWER_SAVE_ON_BAT = 1;
          SOUND_POWER_SAVE_CONTROLLER = "Y";
          BAY_POWEROFF_ON_AC = 0;
          BAY_POWEROFF_ON_BAT = 1;
          RUNTIME_PM_ON_AC = "on";
          RUNTIME_PM_ON_BAT = "auto";
          PCIE_ASPM_ON_AC = "default";
          PCIE_ASPM_ON_BAT = "powersupersave";
          RADEON_POWER_PROFILE_ON_AC = "high";
          RADEON_POWER_PROFILE_ON_BAT = "low";
          RADEON_DPM_STATE_ON_AC = "performance";
          RADEON_DPM_STATE_ON_BAT = "battery";
          RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
          RADEON_DPM_PERF_LEVEL_ON_BAT = "low";
        };
      };

      services.auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
            governor = config.powerconf.saver.batteryGovernor;
            energy_performance_preference = "power";
            platform_profile = "low-power";
            turbo = "never";
          };
          charger = {
            governor = config.powerconf.saver.chargerGovernor;
            energy_performance_preference = "performance";
            platform_profile = "performance";
            turbo = "auto";
          };
        };
      };
      
      systemd.services.powertop-auto-tune = {
        description = "Powertop tunings";
        wantedBy = [ "multi-user.target" ];
        after = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "yes";
          ExecStart = "${pkgs.powertop}/bin/powertop --auto-tune";
        };
      };
      
      boot.kernelParams = [
        "pcie_aspm=force"
        "pcie_aspm.policy=powersupersave"
        "i915.enable_psr=1"
        "i915.enable_fbc=1"
        "processor.max_cstate=5"
        "intel_idle.max_cstate=2"
        "ahci.mobile_lpm_policy=3"
      ];
      
      systemd.oomd = {
        enable = true;
        enableRootSlice = true;
        enableUserSlices = true;
      };
    })
  ];
}
