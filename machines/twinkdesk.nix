{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./hardware/twinkdesk.nix
    ../shared.nix
  ];

  boot = {
    loader.efi.efiSysMountPoint = "/boot/efi";
    supportedFilesystems = {
      btrfs = true;
      zfs = lib.mkForce false;
      ntfs = true;
    };
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services = {
    xserver.videoDrivers = [ "nvidia" ];
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };
  };
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    nvidiaSettings = true;
  };
  virtualisation = {
    vmware.host = {
      extraPackages = with pkgs; [
        open-vm-tools
      ];
      enable = true;
      extraConfig = ''
        mks.gl.allowUnsupportedDrivers = "TRUE"
        mks.vk.allowUnsupportedDevices = "TRUE"
      '';
    };
    libvirtd.enable = true;
  };
  users.users.leo.extraGroups = [
    "audio"
    "libvirtd"
  ];
}
