{ pkgs, ... }:
{
  imports = [
    ./gnome.nix
    ./users.nix
  ];

  console.keyMap = "neoqwertz";
  time.timeZone = "Europe/Berlin";

  boot = {
    kernelPackages = pkgs.linuxPackages_cachyos;
    tmp.cleanOnBoot = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.pcscd.enable = true;

  environment.systemPackages = with pkgs; [
    git
    neovim
  ];
}
