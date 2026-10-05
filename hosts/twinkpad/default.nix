{ user, ... }:
let
  # Bracketed so the EC does not cycle the pack between 79 and 80 on the dock.
  chargeStart = 75;
  chargeEnd = 80;
  battery = "/sys/class/power_supply/BAT0";
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];
  system.stateVersion = "26.05";

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 24 * 1024;
      priority = 0;
    }
  ];

  # The 100M ESP is shared with Windows and holds one ~45M generation. New
  # files are copied before old ones are pruned, and running out of space
  # silently truncates the initrd.
  boot.loader.systemd-boot.configurationLimit = 1;

  services.fprintd.enable = true;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="power_supply", KERNEL=="BAT0", ATTR{charge_control_start_threshold}="${toString chargeStart}", ATTR{charge_control_end_threshold}="${toString chargeEnd}"
  '';

  # udev sees no new device on resume, and the EC forgets the thresholds.
  powerManagement.resumeCommands = ''
    echo ${toString chargeStart} > ${battery}/charge_control_start_threshold
    echo ${toString chargeEnd} > ${battery}/charge_control_end_threshold
  '';

  home-manager.users.${user} =
    { lib, ... }:
    {
      dconf.settings = {
        "org/gnome/desktop/session".idle-delay = lib.hm.gvariant.mkUint32 900;

        "org/gnome/settings-daemon/plugins/media-keys".screensaver = [ "<Super>l" ];

        "org/gnome/desktop/peripherals/touchpad" = {
          tap-to-click = true;
          two-finger-scrolling-enabled = true;
          disable-while-typing = true;
        };
      };
    };
}
