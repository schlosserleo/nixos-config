{inputs, ...}: {
  imports = [
    inputs.aerothemeplasma-nix.nixosModules.aerothemeplasma-nix
  ];
  boot.plymouth.enable = true;
  services = {
    displayManager = {
      sddm.enable = true;
      defaultSession = "aerothemeplasma";
    };
    desktopManager.plasma6.enable = true;
  };
  programs.aeroshell = {
    enable = true;
    fonts.segoe.enable = true;
    polkit.enable = true;
    aerothemeplasma = {
      enable = true;
      sddm.enable = true;
      plymouth.enable = true;
    };
  };
}
