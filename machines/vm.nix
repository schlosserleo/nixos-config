{ ... }:
{
  imports = [
    ./hardware/vm.nix
    ../shared.nix
  ];

  services = {
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
  };
}
