{ pkgs, ... }:
{
  imports = [
    ./btrfs.nix
    ./gnome.nix
    ./users.nix
  ];

  # Priority 5 (the default) keeps zram ahead of the on-disk swapfile, which
  # sits at 0 and so only ever sees pages once zram is genuinely full.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # On a laptop, sleep normally and convert to hibernation once the delay
  # expires, so a lid closed overnight does not arrive at a flat battery.
  # Desktops and VMs never emit a lid event, so this is inert there.
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
      # Tuned for zram, not for the swapfile: swapping into RAM is cheap, and
      # page-cluster=0 disables a readahead that only pays off on slower
      # devices. The swapfile exists for hibernation rather than paging, so it
      # does not matter that these values are wrong for it.
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
}
