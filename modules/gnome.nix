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
