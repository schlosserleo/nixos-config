{ pkgs, ... }:
{
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

	environment.gnome.excludePackages = (with pkgs; [
		epiphany
	]);

  # GNOME ships no tray; Tuta Mail needs one.
  environment.systemPackages = [ pkgs.gnomeExtensions.appindicator ];

  nixpkgs.overlays = [
    (final: prev: {

      # The fingerprint row needs the org.gnome.login-screen schema, which
      # ships with gdm; wrapGAppsHook only exposes build inputs' schemas.
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
