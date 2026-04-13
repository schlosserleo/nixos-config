{
  pkgs,
  ...
}:

{
  imports = [
    ./modules/gnome.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot = {
    supportedFilesystems = {
      exfat = true;
    };
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  console.keyMap = "neoqwertz";

  time.timeZone = "Europe/Berlin";

  users = {
    mutableUsers = false;
    users = {
      leo = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPassword = "$y$j9T$yNdH78UHzeQnPlNXL9mhl1$lCFH86eSjuG9Og.gpBXDavWOpbZE0dYb/jeaRr2V3R5";
      };
      root.initialHashedPassword = "$y$j9T$uJcKGpp54PUa26YSvcx2p/$uTtpTgM5iCGMy8TbZMic34Cy4AuL6Nr8leJi0UVxPT.";
    };
  };

  services = {
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
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
      settings = {
        PermitRootLogin = "prohibit-password";
      };
    };
    udev.packages = [ pkgs.yubikey-personalization ];
    pcscd.enable = true;
    pipewire.enable = true;
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
