{ config, lib, pkgs, ... }:
{
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

    brscan5
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
    xsane

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
}
