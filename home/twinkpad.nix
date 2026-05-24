{pkgs, ...}: {
  imports = [
    ./common.nix
    ../modules/home/dconf.nix
  ];

  home.packages = with pkgs; [
    epiphany
    loupe
    steam
    picard
    lollypop
  ];
}
