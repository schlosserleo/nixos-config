{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.enable = true;
  dconf.settings = {
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      workspaces-only-on-primary = false;
    };
    "org/gnome/desktop/input-sources" = {
      show-all-sources = true;
      sources = [
        (mkTuple [
          "xkb"
          "de+neo_qwertz"
        ])
      ];
    };
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Shift><Super>q" ];
      minimize = [ ];
      move-to-workspace-1 = [ "<Shift><Super>1" ];
      move-to-workspace-2 = [ "<Shift><Super>2" ];
      move-to-workspace-3 = [ "<Shift><Super>3" ];
      move-to-workspace-4 = [ "<Shift><Super>4" ];
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      toggle-fullscreen = [ "<Super>f" ];
    };
    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [ "<Shift><Super>s" ];
      switch-to-application-1 = [ ];
      switch-to-application-2 = [ ];
      switch-to-application-3 = [ ];
      switch-to-application-4 = [ ];
    };
    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 0;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
    };
    "org/gnome/desktop/peripherals/keyboard" = {
      delay = mkUint32 319;
      repeat-interval = mkUint32 16;
    };

    "org/gnome/shell" = {
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "focuscontrol@itsfernn"
        "tiling-assistant@leleat-on-github"
      ];
      favorite-apps = [
        "com.mitchellh.ghostty.desktop"
        "org.gnome.Nautilus.desktop"
        "zen-beta.desktop"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
      screensaver = [ ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "xdg-terminal";
      name = "Terminal";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Super>e";
      command = "nautilus -w";
      name = "File Explorer";
    };
    "org/gnome/shell/extensions/focuscontrol" = {
      focus-down = [ "<Super>j" ];
      focus-left = [ "<Super>h" ];
      focus-right = [ "<Super>l" ];
      focus-up = [ "<Super>k" ];
    };
    "org/gnome/shell/extensions/tiling-assistant" = {
      center-window = [ "<Shift><Super>c" ];
      dynamic-keybinding-behavior = 2;
      enable-advanced-experimental-features = true;
      enable-tiling-popup = false;
      last-version-installed = 54;
      maximize-with-gap = true;
      single-screen-gap = 6;
      tile-bottom-half = [ "<Shift><Super>j" ];
      tile-left-half = [ "<Shift><Super>h" ];
      tile-maximize = [ "<Shift><Super>f" ];
      tile-right-half = [ "<Shift><Super>l" ];
      tile-top-half = [ "<Shift><Super>k" ];
      toggle-tiling-popup = [ ];
      window-gap = 6;
    };
  };
}
