{
  config,
  lib,
  pkgs,
  user,
  ...
}:
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

  # s2idle only, so a closed lid has to reach hibernate. Offset from
  # `btrfs inspect-internal map-swapfile -r /swap/swapfile`.
  boot.resumeDevice = "/dev/disk/by-uuid/ff46ee8a-b7ae-4222-a27f-c5f2e287af36";
  boot.kernelParams = [ "resume_offset=2630912" ];

  # amdgpu crashes soon after resuming from hibernate on cachyos 7.2.4.
  # Trying mainline to see whether the bug follows the kernel.
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

  # 100M ESP shared with Windows: ~63M usable against ~45M per generation, so
  # one fits. The builder copies before it prunes, so overflowing leaves a
  # truncated initrd rather than failing. Keep the initrd small.
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
        # One idle-delay covers both power sources.
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
