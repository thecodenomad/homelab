{ config, lib, pkgs, ... }:
{
  #===============================#
  # Desktop Environment Selection #
  #===============================#

  # -= Cinnamon =-
  # services.xserver.desktopManager.enlightenment.enable = true;

  # -= Enlightenment =-
  # services.xserver.desktopManager.enlightenment.enable = true;

  # -= Gnome =-
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # -= LXQT =-
  # services.xserver.desktopManager.lxqt.enable = true;

  # -= Mate =-
  # services.xserver.desktopManager.mate.enable = true;

  # -= Pantheon =-
  #
  # NOTE: The following enables/installs lightdm by default.
  #       lightdm is required for screen locking/unlocking in patheon.
  #       By default Pantheon installs all it's own apps.
  # services.xserver.desktopManager.pantheon.enable = true;
  # services.pantheon.apps.enable = false;

  # -= Plasma =-
  #
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # -= XFCE =-
  # services.xserver.desktopManager.xfce.enable

  #======================#
  # System Configuration #
  #======================#

  # X Configuration
  services.xserver.enable  = true;
  services.xserver.layout = "us";
  services.xserver.libinput.enable = true;

  # Enable Video Hardware Acceleration
  hardware.video.hidpi.enable = true;
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      mesa_drivers
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}