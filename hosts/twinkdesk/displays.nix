{ user, ... }:
let
  # Keeping this in the repo means the layout survives a fresh install.
  monitors = ./monitors.xml;
in
{
  home-manager.users.${user}.xdg.configFile."monitors.xml".source = monitors;

  # The copy GDM reads: the greeter inherits no XDG_CONFIG_DIRS, so glib falls
  # back to /etc/xdg. Its own ~/.config is tmpfs, torn down with the session.
  environment.etc."xdg/monitors.xml".source = monitors;
}
