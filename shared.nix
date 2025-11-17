{
  pkgs,
  ...
}:

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
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  console.keyMap = "neoqwertz";

  time.timeZone = "Europe/Berlin";

  users.mutableUsers = false;
  users.users.leo = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$y$j9T$yNdH78UHzeQnPlNXL9mhl1$lCFH86eSjuG9Og.gpBXDavWOpbZE0dYb/jeaRr2V3R5";
  };

  services = {
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
    # btrfs.autoScrub = {
    #   enable = true;
    #   interval = "monthly";
    #   fileSystems = [ "/" ];
    # };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    unzip
    gcc15
    cargo
    tealdeer
  ];

  system.stateVersion = "25.11";
}
