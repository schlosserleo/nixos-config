{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware/vm2.nix
    ../shared.nix
  ];

  virtualisation.vmware = {
    guest.enable = true;
  };
}
