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

  networking.hostName = "twinkdesk";

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
    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "smbnixdesk";
          "netbios name" = "smbnixdesk";
          "security" = "user";
          "hosts allow" = "192.168.178. 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
        "public" = {
          "path" = "/home/leo/Music/";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "leo";
          "force group" = "users";
        };
      };
    };
    samba-wsdd = {
      enable = true;
      openFirewall = true;
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
