{...}: {
  imports = [
    ./hardware/vm.nix
    ../shared.nix
  ];

  virtualisation.vmware.guest.enable = true;
}
