{
  config,
  pkgs,
  user,
  ...
}:
let
  # Stop charging at 80% and only resume below 75%. Bracketing the two keeps
  # the EC from cycling the pack between 79 and 80 all day on the dock.
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

  # The panel only supports s2idle, so a closed lid keeps drawing power until
  # common.nix hands the session to hibernate; that needs somewhere to resume
  # from. Offset from `btrfs inspect-internal map-swapfile -r /swap/swapfile`;
  # check-resume-offset re-verifies it on every boot.
  boot.resumeDevice = "/dev/disk/by-uuid/ff46ee8a-b7ae-4222-a27f-c5f2e287af36";
  boot.kernelParams = [ "resume_offset=2630912" ];

  # Synaptics 06cb:00f9, in the power button. libfprint drives it; enrol with
  # `fprintd-enroll` before it does anything.
  services.fprintd.enable = true;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="power_supply", KERNEL=="BAT0", ATTR{charge_control_start_threshold}="${toString chargeStart}", ATTR{charge_control_end_threshold}="${toString chargeEnd}"
  '';

  # The EC drops the thresholds across hibernation, and udev sees no new device
  # on resume, so re-apply them by hand.
  powerManagement.resumeCommands = ''
    echo ${toString chargeStart} > ${battery}/charge_control_start_threshold
    echo ${toString chargeEnd} > ${battery}/charge_control_end_threshold
  '';

  home-manager.users.${user} =
    { lib, ... }:
    {
      dconf.settings = {
        # GNOME keeps one idle-delay for both power sources. 15 minutes is long
        # enough not to interrupt reading and short enough to matter unplugged.
        "org/gnome/desktop/session".idle-delay = lib.hm.gvariant.mkUint32 900;

        # A machine that leaves the house needs a lock shortcut.
        "org/gnome/settings-daemon/plugins/media-keys".screensaver = [ "<Super>l" ];

        "org/gnome/desktop/peripherals/touchpad" = {
          tap-to-click = true;
          two-finger-scrolling-enabled = true;
          disable-while-typing = true;
        };
      };
    };
}
