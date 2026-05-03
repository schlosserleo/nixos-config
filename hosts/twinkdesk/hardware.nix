{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [];
    };
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
  };

  fileSystems = let
    rootDevice = "/dev/disk/by-uuid/bdf2bf8b-391b-479b-96fc-1caf8e891c2c";
    btrfsSubvol = subvol: opts: {
      device = rootDevice;
      fsType = "btrfs";
      options = ["compress=zstd" "subvol=${subvol}"] ++ opts;
    };
  in {
    "/" = btrfsSubvol "@" [];
    "/nix" = btrfsSubvol "@nix" ["noatime"];
    "/home" = btrfsSubvol "@home" [];
    "/swap" = btrfsSubvol "@swap" ["noatime"];
    "/boot/efi" = {
      device = "/dev/disk/by-uuid/897C-BACC";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
  };

  swapDevices = [{device = "/swap/swapfile";}];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
