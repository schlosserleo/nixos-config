{ pkgs, ... }:
{
  imports = [
    ./hardware/twinkpad.nix
    ../shared.nix
  ];
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-eevdf;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  environment.systemPackages = with pkgs; [
    vulkan-tools
  ];
}
