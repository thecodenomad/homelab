{ config, lib, pkgs, ... }:
{
  # Setup scanner
  hardware.sane.enable = true;
  hardware.sane.brscan5.enable = true;

  # Printer Setup
  services.avahi.enable    = true;
  services.avahi.nssmdns   = true;
  services.printing.enable = true;

  #===========#
  # Overrides #
  #===========#

  nixpkgs.config.packageOverrides = pkgs: {
    xsaneGimp = pkgs.xsane.override { gimpSupport = true; };
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
}