{ config, lib, pkgs, ... }:
{
  #=============================#
  # Frame.work All things power #
  #=============================#

  # Set default power options
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # Enable thermal data
  services.thermald.enable = true;

  # Hibernation config
  systemd.sleep.extraConfig = "HibernateDelaySec=2h";
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      IdleAction=suspend-then-hibernate
      IdleActionSec=2m
    '';
  };

  # Additional boot params for power management sake
  # re: https://discourse.nixos.org/t/thinkpad-t470s-power-management/8141
  boot.extraModprobeConfig = lib.mkMerge [
    # idle audio card after one second
    "options snd_hda_intel power_save=1"

    # enable wifi power saving (keep uapsd off to maintain low latencies)
    "options iwlwifi power_save=1 uapsd_disable=1"
  ];

#  Jury is still out Gnome Power Management vs TLP
#  services.tlp = {
#      enable = true;
#      extraConfig = ''
#        START_CHARGE_THRESH_BAT0=75
#        STOP_CHARGE_THRESH_BAT0=80
#
#        CPU_SCALING_GOVERNOR_ON_AC=performance
#        CPU_SCALING_GOVERNOR_ON_BAT=powersave
#
#        # Framework specifics based on i7-1165G7 specs
#        CPU_SCALING_MIN_FREQ_ON_AC=1200000
#        CPU_SCALING_MAX_FREQ_ON_AC=4700000
#        CPU_SCALING_MIN_FREQ_ON_BAT=1200000
#        CPU_SCALING_MAX_FREQ_ON_BAT=2800000
#
#        # Enable audio power saving for Intel HDA, AC97 devices (timeout in secs).
#        # A value of 0 disables, >=1 enables power saving (recommended: 1).
#        # Default: 0 (AC), 1 (BAT)
#        SOUND_POWER_SAVE_ON_AC=0
#        SOUND_POWER_SAVE_ON_BAT=1
#
#        # Runtime Power Management for PCI(e) bus devices: on=disable, auto=enable.
#        # Default: on (AC), auto (BAT)
#        RUNTIME_PM_ON_AC=on
#        RUNTIME_PM_ON_BAT=auto
#      '';
#  };

}
