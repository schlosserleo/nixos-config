{ pkgs, currentSystemName, ... }:

{
  imports = [
    ./modules/gnome.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  nix = {
    settings = {
    substituters = [
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  networking.hostName = "${currentSystemName}";
  time.timeZone = "Europe/Berlin";

  users.mutableUsers = false;
  fonts.fontDir.enable = true;
  system.stateVersion = "25.11";
}
