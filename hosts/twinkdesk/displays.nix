{ user, ... }:
let
  monitors = ./monitors.xml;
in
{
  home-manager.users.${user}.xdg.configFile."monitors.xml".source = monitors;

  # GDM's copy: the greeter has no XDG_CONFIG_DIRS, so glib falls back to
  # /etc/xdg, and its own ~/.config is a tmpfs.
  environment.etc."xdg/monitors.xml".source = monitors;
}
