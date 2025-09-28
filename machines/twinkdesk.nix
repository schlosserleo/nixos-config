{ config, ... }:
{
  imports = [
    ./hardware/twinkdesk.nix
    ../shared.nix
  ];
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
}
