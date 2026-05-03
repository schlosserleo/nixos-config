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
  ];

  networking = {
    hostName = "twinkdesk";
    # FIXME: re-enable and explicitly open required ports
    firewall.enable = false;
    hosts."192.168.136.197" = [
      "nextcloud.local"
      "vaultwarden.local"
      "forgejo.local"
      "files.local"
    ];
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

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = [pkgs.nvidia-vaapi-driver];
    };
    nvidia = {
      modesetting.enable = true;
      open = false;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      nvidiaSettings = true;
    };
  };

  services = {
    xserver.videoDrivers = ["nvidia"];
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

  systemd = {
    tmpfiles.rules = [
      "L+ /var/lib/gdm/seat0/config/monitors.xml - - - - ${monitorsXml}"
    ];
    # Workaround: upstream unit's ExecStart fails on this system; clear and reissue with explicit shell.
    # services."virt-secret-init-encryption".serviceConfig.ExecStart = lib.mkForce [
      # ""
      # "/bin/sh -c 'umask 0077 && (dd if=/dev/random status=none bs=32 count=1 | systemd-creds encrypt --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key)'"
    # ];
  };

  users.users.leo.extraGroups = [
    "audio"
    "libvirtd"
  ];
}
