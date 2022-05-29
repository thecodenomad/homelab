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
    ];

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
 
  # Additional boot params for power management sake
  # re: https://discourse.nixos.org/t/thinkpad-t470s-power-management/8141
  boot.extraModprobeConfig = lib.mkMerge [
    # idle audio card after one second
    "options snd_hda_intel power_save=1"

    # enable wifi power saving (keep uapsd off to maintain low latencies)
    "options iwlwifi power_save=1 uapsd_disable=1"
  ];

  #==================#
  # All things power #
  #==================#

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

  # Networking 
  networking.networkmanager.enable = true;
  networking.hostName = "chunk";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # Timezone
  time.timeZone = "America/Denver";

  # Internationalization and keymap in X11
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Setup scanner
  hardware.sane.enable = true;
  hardware.sane.dsseries.enable = true;
  hardware.sane.brscan5.enable = true;  

  # Configure Pipewire Audio
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Setup Virtualization
  # virtualisation.virtualbox.host.enable = "true";
  virtualisation.docker.enable = true;

  #==================#
  # Enabled Services #
  #==================#

  services.avahi.enable    = true;
  services.avahi.nssmdns   = true;
  services.fwupd.enable    = true;
  services.gvfs.enable     = true;
  services.openssh.enable  = true;
  services.printing.enable = true;
  
  #===========#
  # Overrides #
  #===========#

  nixpkgs.config.packageOverrides = pkgs: {
    xsaneGimp = pkgs.xsane.override { gimpSupport = true; };
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  #=====================#
  # Software to Install #
  #=====================#

  # TODO: Need to figure out how to only unmask certain applications, unfreePredicate
  #       doesn't seem to do what is wanted.
  nixpkgs.config.allowUnfree = true;

  # System level Environment Variables
  environment.sessionVariables = {
   MOZ_ENABLE_WAYLAND = "1";
  };

  environment.systemPackages = with pkgs; [
    #--------#
    # Themes #
    #--------#

    arc-theme
    ant-theme
    canta-theme
    equilux-theme
    juno-theme
    mojave-gtk-theme
    numix-gtk-theme
    oceanic-theme
    orchis-theme
    palenight-theme
    plano-theme
    solarc-gtk-theme
    whitesur-gtk-theme

    #-------------#
    # Icon Themes #
    #-------------#

    arc-icon-theme
    flat-remix-icon-theme
    kora-icon-theme
    moka-icon-theme
    maia-icon-theme
    numix-icon-theme
    paper-icon-theme
    papirus-icon-theme
    tela-icon-theme
    tela-circle-icon-theme
    whitesur-icon-theme

    #--------------#
    # Applications #
    #--------------#

    brlaser
    brgenml1lpr
    brgenml1cupswrapper
    calibre
    chromium
    deja-dup
    docker
    exfat
    exfatprogs
    firefox-wayland
    fwupd
    gcc
    git
    gimp
    gnome.gnome-boxes
    gnome.gnome-tweaks
    gnome.networkmanager-l2tp
    gnome.simple-scan
    gnumake
    go
    gparted
    gutenprint
    guvcview
    hplip
    libreoffice
    meld
    networkmanager-l2tp
    openscad
    openvpn
    pandoc
    prusa-slicer
    samba
    sane-backends
    screen
    signal-desktop
    terminator
    transmission
    usbutils
    wget
    vim
    xorg.libX11
    xorg.libX11.dev

    #-----------------#
    # Unfree software #
    #-----------------#

    jetbrains.pycharm-professional
    jetbrains.goland
    jetbrains.datagrip
    slack
    spotify
    vscode
  ];

  #====================#
  # User Configuration #
  #====================#

  users.users.codenomad = {
    isNormalUser = true;
    extraGroups = [ "docker" "wheel" "video" "audio" "disk" "networkmanager" "scanner" "lp" ];
  };

  #===========================#
  # Don't touch after install #
  #===========================#

  # Set this to the current release version and don't change after bare-metal install.
  system.stateVersion = "22.05";
}

