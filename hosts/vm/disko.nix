{ lib, ... }:
let
  # zstd:3 is the btrfs default level and the right tradeoff on an SSD -- it
  # costs less CPU than the read it saves. noatime avoids a metadata write
  # (and therefore a CoW) every time a file is merely read.
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
              # Reproducible from the flake, so deliberately never snapshotted:
              # snapshots here would pin store paths the GC is trying to free.
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = opts;
              };
              # Split out so that rolling @ back to a snapshot does not also
              # roll back the journal explaining why you rolled back.
              "@log" = {
                mountpoint = "/var/log";
                mountOptions = opts;
              };
              # Holds the snapshots of @ itself, so it has to live outside @.
              "@snapshots" = {
                mountpoint = "/.snapshots";
                mountOptions = opts;
              };
              # No compress= here: btrfs refuses a swapfile that is compressed
              # or copy-on-write. mkswapfile sets NOCOW on the file itself;
              # leaving compression off the subvolume keeps it usable.
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

  # Mount in stage 1 so journald writes to the real /var/log from the start
  # instead of buffering into /run and flushing across the pivot.
  fileSystems."/var/log".neededForBoot = lib.mkForce true;
}
