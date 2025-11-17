{ pkgs, ... }:
{
  imports = [ ./shared.nix ];
  home.packages = with pkgs; [
    vmware-workstation
    open-vm-tools
  ];
}
