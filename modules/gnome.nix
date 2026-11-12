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
    })
  ];
}
