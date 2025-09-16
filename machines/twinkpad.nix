{ pkgs, ... }:
{
  imports = [
    ./hardware/twinkpad.nix
    ../shared.nix
  ];
  # services = {
  #   fwupd.enable = true;
  #   thermald.enable = true;
  #   power-profiles-daemon.enable = true;
  #   fprintd.enable = true;
  # };


  home.packages = with pkgs; [
    decibels
    gapless
    nicotine-plus
    qbittorrent-enhanced
    picard
  ];
}
