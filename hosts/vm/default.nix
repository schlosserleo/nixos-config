{...}: {
  imports = [
    ./hardware.nix
    ../common.nix
  ];

  virtualisation.vmware.guest.enable = true;
}
