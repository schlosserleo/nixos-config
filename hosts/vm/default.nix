{ ... }:
{
  imports = [ 
    ./hardware-configuration.nix 
    ./disko.nix
  ];
  system.stateVersion = "26.05";

  virtualisation.vmware.guest.enable = true;

  # Hibernation writes all of RAM out here, so the file has to be at least
  # RAM-sized (31 GiB on this host). Priority 0 puts it below zram: this is
  # for hibernation, not for day-to-day paging.
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 32 * 1024;
      priority = 0;
    }
  ];

  # Resuming from a swapfile needs the block device plus the file's physical
  # offset within it, because at resume time there is no filesystem yet to
  # look the extent up in. Read off the created file with:
  #   btrfs inspect-internal map-swapfile -r /swap/swapfile
  # Recreating the swapfile moves it, so both values must be refreshed then.
  boot.resumeDevice = "/dev/disk/by-uuid/fc0029e4-2836-4526-85ca-c4fcb8d0eec1";
  boot.kernelParams = [ "resume_offset=2248617" ];
}
