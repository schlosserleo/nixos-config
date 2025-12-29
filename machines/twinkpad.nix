{ pkgs, ... }:
{
  # nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
  # nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
  imports = [
    ./hardware/twinkpad.nix
    ../shared.nix
  ];
  # boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-eevdf;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  environment.systemPackages = with pkgs; [
    vulkan-tools
  ];
}
