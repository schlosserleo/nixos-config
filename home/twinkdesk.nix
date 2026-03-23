{ pkgs, ... }:
{
  imports = [ ./shared.nix ];
  nixpkgs.config = {
    android_sdk.accept_license = true;
  };
  home.packages = with pkgs; [
    steam
    mpv
    google-chrome
    qbittorrent
    virt-manager
    showtime
    papers
    kdePackages.isoimagewriter
    libreoffice-fresh
    android-tools
  ];
}
