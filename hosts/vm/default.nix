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
}
