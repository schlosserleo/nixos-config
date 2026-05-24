{pkgs, ...}: {
  services = {
    displayManager.gdm = {
      enable = true;
    };
    desktopManager.gnome.enable = true;
    udev.packages = [pkgs.gnome-settings-daemon];
  };

  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.tiling-assistant
    gnomeExtensions.focus-changer
    gnome-tweaks
  ];
}
