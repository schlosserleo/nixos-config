{
  inputs,
  pkgs,
  ...
}: let
  pkgs-master = import inputs.nixpkgs-master {
    system = pkgs.stdenv.hostPlatform.system;
    config = pkgs.config;
  };
in {
  imports = [./shared.nix];
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
    pkgs-master.zed-editor
  ];
}
