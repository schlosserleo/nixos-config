{ lib, ... }:

let
  opts = [ "compress=zstd" "noatime" ];
in
{
  disko.devices.disk.main = {
    type = "disk";
    device =
      "/dev/disk/by-partuuid/6fd2db9c-3356-421d-94a9-d46996949360";

    content = {
      type = "btrfs";
      extraArgs = [ "-f" ];

      subvolumes = {
        "@" = {
          mountpoint = "/";
          mountOptions = opts;
        };

        "@home" = {
          mountpoint = "/home";
          mountOptions = opts;
        };

        "@nix" = {
          mountpoint = "/nix";
          mountOptions = opts;
        };

        "@log" = {
          mountpoint = "/var/log";
          mountOptions = opts;
        };

        "@snapshots" = {
          mountpoint = "/.snapshots";
          mountOptions = opts;
        };

        "@swap" = {
          mountpoint = "/swap";
          mountOptions = [ "noatime" ];
        };
      };
    };
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0824-235B";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  fileSystems."/var/log".neededForBoot = lib.mkForce true;
}
