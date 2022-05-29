{ config, lib, pkgs, ... }:
{
  #====================#
  # User Configuration #
  #====================#

  users.users.codenomad = {
    isNormalUser = true;
    extraGroups = [ "docker" "wheel" "video" "audio" "disk" "networkmanager" "scanner" "lp" ];
  };

#  # TODO: Examples (re: https://github.com/jordangarrison/nix-config)
#  home.file = {
#    # Btop
#    ".config/btop/btop.conf".source = ./tools/btop/btop.conf.yml;
#    # Scripts
#    ".local/bin/tmux-cht.sh".source = ./tools/scripts/tmux-cht.sh;
#    ".tmux-cht-languages".source = ./tools/scripts/tmux-cht-languages.txt;
#    ".tmux-cht-commands".source = ./tools/scripts/tmux-cht-commands.txt;
#  };

}