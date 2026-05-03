{
  pkgs,
  config,
  lib,
  inputs,
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
    firewall.enable = false;
    hosts = {
      "192.168.136.197" = ["nextcloud.local" "vaultwarden.local" "forgejo.local" "files.local"];
    };
  };

  # Binary caches from nix-cachyos-kernel maintainer — avoids rebuilding deno/kernel from scratch.
  # NOTE: apply this config BEFORE enabling the cachyos kernel so the cache is active in time.
  nix.settings = {
    #   # Option A: maintainer's Attic cache
    #   substituters = [ "https://attic.xuyh0120.win/lantian" ];
    #   trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
    #   # Option B: Garnix CI cache
    extra-substituters = ["https://cache.garnix.io" "https://attic.xuyh0120.win/lantian"];
    extra-trusted-public-keys = ["cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];
  };

  boot = {
    loader.efi.efiSysMountPoint = "/boot/efi";
    kernelPackages = pkgs.linuxPackagesFor inputs.nix-cachyos-kernel.packages.x86_64-linux.linux-cachyos-latest;
    # kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = {
      btrfs = true;
      zfs = lib.mkForce false;
      ntfs = true;
    };
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [nvidia-vaapi-driver];
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
    # package = config.boot.kernelPackages.nvidiaPackages.beta;
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
