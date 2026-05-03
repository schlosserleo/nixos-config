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
        "thunderbolt"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [];
    };
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
  };

  fileSystems = let
    rootDevice = "/dev/disk/by-uuid/8d29e8da-49ad-46f4-b0d4-4e2cb5ef47f3";
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
    "/boot" = {
      device = "/dev/disk/by-uuid/B86F-1FCE";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
  };

  swapDevices = [{device = "/swap/swapfile";}];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
