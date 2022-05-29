{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Home Manager stuffs
      "${builtins.fetchTarball https://github.com/nix-community/home-manager/archive/master.tar.gz}/nixos"     
      
      # Framework Laptop Hardware imports (refference: https://github.com/NixOS/nixos-hardware)
      "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/framework"

      # Framework Laptop Setup
      "./desktop_environment.nix"
      "./networking.nix"
      "./power.nix"
      "./software.nix"
      "./sound.nix"

      # Raystros customizations
       "../raystros/homelab_hardware.nix"
       "../raystros/homelab_users.nix"
    ];

  # Helps with storage
  nix.autoOptimiseStore = true;

  #=================#
  # All things boot #
  #=================#

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # For Full Disk Encryption
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/nvme0n1p2";
      preLVM = true;
    };
  };

  # Timezone
  time.timeZone = "America/Denver";

  # Internationalization and keymap in X11
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Setup Virtualization
  # virtualisation.virtualbox.host.enable = "true";
  virtualisation.docker.enable = true;

  #==================#
  # Enabled Services #
  #==================#

  services.fwupd.enable    = true;
  services.gvfs.enable     = true;
  services.openssh.enable  = true;

  #===========================#
  # Don't touch after install #
  #===========================#

  # Set this to the current release version and don't change after bare-metal install.
  system.stateVersion = "22.05";
}

