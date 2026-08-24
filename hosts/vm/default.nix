{ ... }:
{
  imports = [ 
    ./hardware-configuration.nix 
    ./disko.nix
  ];
  system.stateVersion = "26.05";

  virtualisation.vmware.guest.enable = true;
}
