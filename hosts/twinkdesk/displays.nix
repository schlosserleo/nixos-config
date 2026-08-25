{ user, ... }:
let
  # GNOME Settings writes this file when displays are rearranged. Keeping the
  # copy in the repo authoritative means the layout survives a fresh install.
  monitors = ./monitors.xml;
in
{
  home-manager.users.${user}.xdg.configFile."monitors.xml".source = monitors;

  # And this is the copy GDM reads. mutter looks for monitors.xml in every
  # XDG system config dir before it looks at the per-user one, and the greeter
  # inherits no XDG_CONFIG_DIRS, so glib falls back to /etc/xdg. Dropping it
  # in the greeter's own ~/.config does not work: the greeter runs as
  # gdm-greeter, whose home lives on tmpfs under /run/gdm/home and is torn
  # down with the session.
  environment.etc."xdg/monitors.xml".source = monitors;
}
