{ pkgs, ... }:
{
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

	environment.gnome.excludePackages = (with pkgs; [
		epiphany
	]);

  # GNOME ships no tray; Tuta Mail needs one to stay reachable in the background.
  environment.systemPackages = [ pkgs.gnomeExtensions.appindicator ];

  nixpkgs.overlays = [
    (final: prev: {

      # Settings hides the fingerprint row unless it can read the
      # org.gnome.login-screen schema, which ships with gdm. wrapGAppsHook
      # builds each app's XDG_DATA_DIRS from its own build inputs, and gdm is
      # not one of gnome-control-center's, so on NixOS the schema is invisible
      # to it and the row vanishes however well fprintd is set up.
      gnome-control-center = prev.gnome-control-center.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ prev.gdm ];
      });
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
