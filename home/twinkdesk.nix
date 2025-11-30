{ pkgs, ... }:
{
  imports = [ ./shared.nix ];
  home.packages = with pkgs; [
    steam
    google-chrome
    virt-manager
  ];
}
