{ pkgs, ... }:
{
  imports = [ ./shared.nix ];
  home.packages = with pkgs; [
    gnome-console
    epiphany
    loupe
    steam
    prismlauncher
    gnome-system-monitor
    gnome-disk-utility
    gnome-remote-desktop
  ];
}
