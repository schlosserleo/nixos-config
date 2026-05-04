{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
    ../common.nix
    ../../modules/nixos/flatpak.nix
  ];

  networking = {
    hostName = "twinkpad";
    firewall = {
      enable = true;
      allowedTCPPorts = [3389];
      allowedUDPPorts = [3389];
      allowPing = true;
    };
  };

  boot.kernelPackages = pkgs.linuxPackagesFor inputs.nix-cachyos-kernel.packages.x86_64-linux.linux-cachyos-latest;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };

  systemd.services."gnome-remote-desktop".wantedBy = ["graphical.target"];

  services = {
    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "smbnix";
          "netbios name" = "smbnix";
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
  };
}
