{ config, lib, pkgs, ... }:
{
  networking.networkmanager.enable = true;
  networking.hostName = "chunk";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
}