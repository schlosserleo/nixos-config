{ ... }:
{
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  nixpkgs.overlays = [
    (final: prev: {
      # Backports from GNOME 51: custom liveries failed to deserialise, and
      # saving one wrote the red channel into the blue one.
      gnome-console = prev.gnome-console.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace src/kgx-livery-manager.c \
            --replace-fail '"(&sv)"' '"{&sv}"'
          substituteInPlace src/kgx-palette.c \
            --replace-fail 'self->foreground.red);' 'self->foreground.blue);' \
            --replace-fail 'self->background.red);' 'self->background.blue);'
        '';
      });
    })
  ];
}
