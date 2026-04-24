{
  pkgs,
  config,
  lib,
  ...
}: let
  monitorsXml = pkgs.writeTextFile {
    name = "twinkdesk-monitors.xml";
    text = builtins.readFile ../home/config/twinkdesk.xml;
  };
in {
  imports = [
    ./hardware/twinkdesk.nix
    ../shared.nix
  ];

  networking = {
    hostName = "twinkdesk";
    firewall.allowedUDPPorts = [ 1900 ];
  };

  boot = {
    loader.efi.efiSysMountPoint = "/boot/efi";
    kernelPackages = pkgs.linuxPackages_testing;
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
    udev = {
      extraRules = ''
        KERNEL=="hidraw*", ATTRS{idVendor}=="4b42", ATTRS{idProduct}=="0105", TAG+="uaccess"
      '';
    };
    flatpak.enable = true;
    xserver.videoDrivers = ["nvidia"];
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
  systemd = {
    tmpfiles.rules = [
      "L+ /var/lib/gdm/seat0/config/monitors.xml - - - - ${monitorsXml}"
    ];
    services."virt-secret-init-encryption".serviceConfig.ExecStart = lib.mkForce [
      "" # clears the original ExecStart
      "/bin/sh -c 'umask 0077 && (dd if=/dev/random status=none bs=32 count=1 | systemd-creds encrypt --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key)'"
    ];
  };
  users.users.leo.extraGroups = [
    "audio"
    "libvirtd"
    "adbusers"
  ];
}
