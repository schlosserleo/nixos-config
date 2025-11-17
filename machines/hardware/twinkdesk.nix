{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/bdf2bf8b-391b-479b-96fc-1caf8e891c2c";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "subvol=@"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/bdf2bf8b-391b-479b-96fc-1caf8e891c2c";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
      "subvol=@nix"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/bdf2bf8b-391b-479b-96fc-1caf8e891c2c";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "subvol=@home"
    ];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/bdf2bf8b-391b-479b-96fc-1caf8e891c2c";
    fsType = "btrfs";
    options = [
      "noatime"
      "subvol=@swap"
    ];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/897C-BACC";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

}
