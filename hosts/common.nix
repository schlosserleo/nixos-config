{pkgs, ...}: {
  imports = [
    ../modules/nixos/audio.nix
    ../modules/nixos/gnome.nix
    ../modules/nixos/users.nix
  ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes" "pipe-operators"];
      trusted-users = ["@wheel"];
      warn-dirty = false;
      auto-optimise-store = true;
      extra-substituters = [
        "https://cache.garnix.io"
        "https://attic.xuyh0120.win/lantian"
      ];
      extra-trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    optimise.automatic = true;
  };

  boot = {
    supportedFilesystems.exfat = true;
    tmp.cleanOnBoot = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking.hosts = {
    "100.100.91.26" = ["twinkspace"];
  };

  console.keyMap = "neoqwertz";
  time.timeZone = "Europe/Berlin";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
    };
  };

  services = {
    tailscale.enable = true;
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = ["/"];
    };
    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };
    xserver.xkb = {
      layout = "de";
      variant = "neo_qwertz";
    };
    openssh = {
      enable = true;
      settings.PermitRootLogin = "prohibit-password";
    };
    udev.packages = [pkgs.yubikey-personalization];
    pcscd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    unzip
    tealdeer
    exfatprogs
    dosfstools
    ntfsprogs
  ];

  system.stateVersion = "25.11";
}
