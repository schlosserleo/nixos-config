{ inputs, ... }:
{ config, lib, pkgs, ... }:

{
  dconf.enable = true;
  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" "xwayland-native-scaling" ];
      dynamic-workspaces = false;
    };
    "org/gnome/desktop/input-sources" = {
      show-all-sources = true;
      sources = [ (lib.hm.gvariant.mkTuple [ "xkb" "de+neo_qwertz" ]) ];
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "xdg-terminal-exec";
      name = "Open Terminal";
    };
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Shift><Super>q" ];
      move-to-workspace-1 = [ "<Shift><Super>1" ];
      move-to-workspace-2 = [ "<Shift><Super>2" ];
      move-to-workspace-3 = [ "<Shift><Super>3" ];
      move-to-workspace-4 = [ "<Shift><Super>4" ];
      switch-applications = [];
      switch-applications-backward = [];
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-left = [ "<Shift><Super>Tab" ];
      switch-to-workspace-right = [ "<Super>Tab" ];
      toggle-fullscreen = [ "<Super>f" ];
    };
    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = [];
      switch-to-application-2 = [];
      switch-to-application-3 = [];
      switch-to-application-4 = [];
    };
  };
}
