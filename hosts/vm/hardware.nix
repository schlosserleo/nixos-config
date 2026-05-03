{lib, ...}: {
  boot = {
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "ehci_pci"
        "ahci"
        "xhci_pci"
        "nvme"
        "sr_mod"
      ];
      kernelModules = [];
    };
    kernelModules = [];
    extraModulePackages = [];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/dcd02170-d147-4e9f-b108-ef88cc91fe12";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/CE25-B2A0";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
  };

  swapDevices = [];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
