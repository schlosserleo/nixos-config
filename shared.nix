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
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  networking.hostName = "${currentSystemName}";
  time.timeZone = "Europe/Berlin";

  user.mutableUsers = false;
  fonts.fontDir.enable = true;
  system.stateVersion = "25.11";
}
