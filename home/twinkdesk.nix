{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  home.packages = with pkgs; [
    steam
    mpv
    ungoogled-chromium
    qbittorrent
    virt-manager
    showtime
    papers
    kdePackages.isoimagewriter
    libreoffice-fresh
    android-tools
  ];
  programs.plasma = {
    enable = true;
    configFile = {
      kcminputrc."Libinput/5426/205/Razer Razer Basilisk V3 Pro 35K".PointerAccelerationProfile = 1;
      kcminputrc."Libinput/5426/205/Razer Razer Basilisk V3 Pro 35K Mouse".PointerAccelerationProfile = 1;
    };
  };
}
