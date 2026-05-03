{pkgs, ...}: {
  imports = [./common.nix];

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
    zed-editor
  ];
}
