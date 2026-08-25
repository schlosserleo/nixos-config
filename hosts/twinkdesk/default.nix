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

  hardware.nvidia = {
		modesetting.enable = true;
		powerManagement.enable = true;
		powerManagement.finegrained = true;
		open = true;
		nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
}
