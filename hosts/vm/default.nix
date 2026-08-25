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

  boot.resumeDevice = "/dev/disk/by-uuid/fc0029e4-2836-4526-85ca-c4fcb8d0eec1";
  boot.kernelParams = [ "resume_offset=2248617" ];
}
