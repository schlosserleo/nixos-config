{ pkgs, ... }:
{
  imports = [ ./shared.nix ];
  home.packages = with pkgs; [
    gnome-console
    epiphany
    loupe
  ];
}
