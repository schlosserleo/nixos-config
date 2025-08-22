{ pkgs, inputs, ... }:
let
  fontsPath = ./fonts
  hasFonts = builtins.pathExists fontsPath;

  localFonts = lib.optionalAttrs hasFonts (pkgs.stdenv.mkDerivation {
    name = "leo-fonts"
    src = fontsPath;
    installPhase = ''
      mkdir -p $out/share/fonts
      find . -name "*.otf" -exec cp {} $out/share/fonts/ \;
    '';
  };
in
{
  programs.fish.enable = true;
  users.users.leo = {
    isNormalUser = true;
    home = "/home/leo";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    hashedPassword = "$6$Kccgxupo9BLou66Y$WCAwVbJO5JD4SJLEBYC5qImmABONYgs0spDB9RtzkdMMl4T/krjZW/4MJbnj.jXsDLYWZdYuNqZK28b23700W/";
  };
}
