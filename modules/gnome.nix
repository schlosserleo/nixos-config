{ pkgs, ... }:

{
  services = {
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome.enable = true;
    # gnome = {
      # core-apps.enable = false;
      # core-developer-tools.enable = false;
      # games.enable = false;
    # };
    udev.packages = [ pkgs.gnome-settings-daemon ];
  };
  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.tiling-assistant
    gnomeExtensions.focus-changer
  ];
}
