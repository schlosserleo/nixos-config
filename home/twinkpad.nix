{pkgs, ...}: {
  imports = [./shared.nix];
  home.packages = with pkgs; [
    gnome-console
    epiphany
    loupe
    steam
    gnome-system-monitor
    gnome-disk-utility
    gnome-remote-desktop
    picard
    lollypop
  ];
}
