{ ... }:
{
  imports = [ 
    ./hardware-configuration.nix 
    ./disko.nix
  ];
  system.stateVersion = "26.05";

  virtualisation.vmware.guest.enable = true;

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 32 * 1024;
      priority = 0;
    }
  ];
}
