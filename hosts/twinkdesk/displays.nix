{
  config,
  lib,
  user,
  ...
}:
let
  # GNOME Settings writes this file when displays are rearranged. Keeping the
  # copy in the repo authoritative means the layout survives a fresh install,
  # and gives GDM something to read — see below.
  monitors = ./monitors.xml;

  greeters = lib.filter (u: lib.hasPrefix "gdm-greeter" u.name) (
    lib.attrValues config.users.users
  );
in
{
  home-manager.users.${user}.xdg.configFile."monitors.xml".source = monitors;

  # The greeter runs as its own user (gdm-greeter, plus -2..-5 for further
  # seats) and mutter only looks at $HOME/.config/monitors.xml, so without
  # this GDM comes up with its own idea of the layout. Those homes sit under
  # /run, so they have to be recreated every boot.
  systemd.tmpfiles.rules = lib.concatMap (u: [
    "d ${u.home}/.config 0711 ${u.name} gdm"
    "L+ ${u.home}/.config/monitors.xml - - - - ${monitors}"
  ]) greeters;
}
