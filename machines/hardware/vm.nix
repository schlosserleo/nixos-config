# Auto Generated
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/45aae12c-0719-4ed5-8e34-ba2532be1783";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/45aae12c-0719-4ed5-8e34-ba2532be1783";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/root" =
    { device = "/dev/disk/by-uuid/45aae12c-0719-4ed5-8e34-ba2532be1783";
      fsType = "btrfs";
      options = [ "subvol=@root" ];
    };

  fileSystems."/srv" =
    { device = "/dev/disk/by-uuid/45aae12c-0719-4ed5-8e34-ba2532be1783";
      fsType = "btrfs";
      options = [ "subvol=@srv" ];
    };

  fileSystems."/var/tmp" =
    { device = "/dev/disk/by-uuid/45aae12c-0719-4ed5-8e34-ba2532be1783";
      fsType = "btrfs";
      options = [ "subvol=@tmp" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/45aae12c-0719-4ed5-8e34-ba2532be1783";
      fsType = "btrfs";
      options = [ "subvol=@log" ];
    };

  fileSystems."/var/cache" =
    { device = "/dev/disk/by-uuid/45aae12c-0719-4ed5-8e34-ba2532be1783";
      fsType = "btrfs";
      options = [ "subvol=@cache" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/CE05-6023";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ ];
}
