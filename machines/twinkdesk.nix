{ config, ... }:
{
  imports = [
    ./hardware/twinkdesk.nix
    ../shared.nix
  ];
  boot.loader.efi.efiSysMountPoint = "/boot/efi"; 
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services = {
    xserver.videoDrivers = [ "nvidia" ];
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };
  };
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    nvidiaSettings = true;
  };
}
