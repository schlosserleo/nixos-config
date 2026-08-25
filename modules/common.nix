{ pkgs, user, ... }:
{
  imports = [
    ./btrfs.nix
    ./gnome.nix
    ./users.nix
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend";
  };
  systemd.sleep.settings.Sleep.HibernateDelaySec = "30min";

  console.keyMap = "neoqwertz";
  time.timeZone = "Europe/Berlin";

  boot = {
    kernelPackages = pkgs.linuxPackages_cachyos;
    kernel.sysctl = {
      "vm.swappiness" = 180;
      "vm.page-cluster" = 0;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
    };
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

	programs.nh = {
		enable = true;
		flake = "/home/${user}/Projects/nixos-config";
	};
}
