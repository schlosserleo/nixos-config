{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./displays.nix
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
}
