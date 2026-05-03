{
  pkgs,
  lib,
  inputs,
  ...
}: let
  monitorsXml = pkgs.writeTextFile {
    name = "twinkdesk-monitors.xml";
    text = builtins.readFile ../../home/config/twinkdesk.xml;
  };
in {
  imports = [
    ./hardware.nix
    ../common.nix
    ../../modules/nixos/nvidia.nix
  ];

  networking = {
    hostName = "twinkdesk";
    firewall = {
      enable = true;
      allowPing = true;
    };
  };

  boot = {
    loader.efi.efiSysMountPoint = "/boot/efi";
    kernelPackages = pkgs.linuxPackagesFor inputs.nix-cachyos-kernel.packages.x86_64-linux.linux-cachyos-latest;
    supportedFilesystems = {
      btrfs = true;
      zfs = lib.mkForce false;
      ntfs = true;
    };
  };

  nixpkgs.overlays = [
    (final: _prev: {
      inherit (inputs.nixpkgs-master.legacyPackages.${final.stdenv.hostPlatform.system}) zed-editor;
    })
  ];

  services = {
    flatpak.enable = true;
    udev.extraRules = ''
      KERNEL=="hidraw*", ATTRS{idVendor}=="4b42", ATTRS{idProduct}=="0105", TAG+="uaccess"
    '';
  };

  virtualisation = {
    libvirtd.enable = true;
    vmware.host = {
      enable = true;
      extraPackages = [pkgs.open-vm-tools];
      extraConfig = ''
        mks.gl.allowUnsupportedDrivers = "TRUE"
        mks.vk.allowUnsupportedDevices = "TRUE"
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "L+ /var/lib/gdm/seat0/config/monitors.xml - - - - ${monitorsXml}"
  ];

  users.users.leo.extraGroups = ["libvirtd"];
}
