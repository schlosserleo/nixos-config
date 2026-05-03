{pkgs, ...}: let
  # Launching prismlauncher outside GNOME doesn't expose the gsettings schemas
  # required for native file dialogs and theme detection.
  prismlauncher-wrapped = pkgs.symlinkJoin {
    name = "prismlauncher-wrapped";
    paths = [pkgs.prismlauncher];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/prismlauncher \
        --set XDG_DATA_DIRS "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    '';
  };
in {
  home.packages = [prismlauncher-wrapped pkgs.openjdk25];
}
