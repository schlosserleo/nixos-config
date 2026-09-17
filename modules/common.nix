{
  lib,
  pkgs,
  user,
  ...
}:
{
  imports = [
    ./airvpn.nix
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

  # dconf covers the GNOME session; this is GDM and the console.
  services.xserver.xkb = {
    layout = "de";
    variant = "neo_qwertz";
  };

  i18n.extraLocaleSettings = {
    LC_TIME = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
  };

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
      systemd-boot = {
        enable = true;
        # Each generation costs a kernel and an initrd on the ESP.
        configurationLimit = lib.mkDefault 10;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    optimise.automatic = true;
  };

  services = {
    fwupd.enable = true;
    pcscd.enable = true;
    tailscale.enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    neovim
  ];

  # The client is 32-bit; a bare package has no i686 GL driver to load.
  programs.steam.enable = true;

  programs.nh = {
    enable = true;
    flake = "/home/${user}/Projects/nixos-config";
  };
}
