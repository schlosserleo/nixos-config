{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./displays.nix
    ./disko.nix
  ];
  system.stateVersion = "26.05";

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 24 * 1024;
      priority = 0;
    }
  ];
}
