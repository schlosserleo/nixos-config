{ lib, ... }:

{
  dconf.enable = true;
  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [
        "scale-monitor-framebuffer"
        "xwayland-native-scaling"
      ];
      dynamic-workspaces = false;
    };
    "org/gnome/desktop/input-sources" = {
      show-all-sources = true;
      sources = [
        (lib.gvariant.mkTuple [
          "xkb"
          "de+neo_qwertz"
        ])
      ];
    };
  };
}
