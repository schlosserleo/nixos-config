{ config, pkgs, ... }:
let
  # 595 (beta/production) does not build against kernel 7.2, which dropped
  # linux/of_gpio.h; 610 is the first release that compiles there.
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.latest;
in
{
  imports = [
    ./hardware-configuration.nix
    ./displays.nix
    ./disko.nix
  ];
  system.stateVersion = "26.05";

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 64 * 1024;
      priority = 0;
    }
  ];

  boot.resumeDevice = "/dev/disk/by-uuid/a385b773-b84f-43f1-9136-93e2ec342628";
  boot.kernelParams = [ "resume_offset=2214173" ];

  # hardware.nvidia only takes effect when the driver is selected here.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    # 32-bit driver userspace, for Steam/Proton and wine.
    graphics.enable32Bit = true;

    nvidia = {
      modesetting.enable = true;
      # Saves and restores VRAM across suspend and hibernate.
      powerManagement.enable = true;
      # Runtime D3 needs PRIME offload, which this desktop does not use.
      powerManagement.finegrained = false;
      open = true;
      # nvidia-settings is a GTK3 app, and GTK3 drags in cups, which is
      # currently marked broken in nixpkgs. Its panels are X11-only anyway.
      nvidiaSettings = false;

      package = nvidiaPackage // {
        # The CachyOS kernel zstd-compresses modules during modules_install,
        # so nixpkgs' strip pass no longer sees them and DWARF sections keep a
        # reference to the kernel .dev output, which trips the driver's empty
        # allowedReferences. Strip inside modules_install instead, before the
        # module is compressed.
        open = nvidiaPackage.open.overrideAttrs (old: {
          installFlags = (old.installFlags or [ ]) ++ [ "INSTALL_MOD_STRIP=1" ];
        });
      };
    };
  };

  environment.systemPackages = [ pkgs.nvtopPackages.nvidia ];

  networking.firewall.allowedTCPPorts = [ 80 ];
}
