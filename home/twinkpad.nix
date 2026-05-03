{pkgs, ...}: {
  imports = [./common.nix];

  home.packages = with pkgs; [
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
