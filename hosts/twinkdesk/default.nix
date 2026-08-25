{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];
  system.stateVersion = "26.05";

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 64 * 1024;
      priority = 0;
    }
  ];

  boot.resumeDevice = "/dev/disk/by-uuid/a385b773-b84f-43f1-9136-93e2ec342628";
  boot.kernelParams = [ "resume_offset=2214173" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
