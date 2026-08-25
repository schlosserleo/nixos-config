{ lib, ... }:
let
  opts = [ "compress=zstd" "noatime" ];
in
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-VMware_Virtual_NVMe_Disk_VMware_NVME_0000";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          type = "8304";
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
      };
    };
  };

  fileSystems."/var/log".neededForBoot = lib.mkForce true;
}
