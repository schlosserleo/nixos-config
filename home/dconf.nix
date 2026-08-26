{lib, ...}: let
  inherit (lib.hm.gvariant) mkTuple mkUint32;
in {
  dconf = {
    enable = true;
    settings = {
      "system/locale".region = "de_DE.UTF-8";

      "org/gnome/desktop/input-sources" = {
        show-all-sources = true;
        sources = [(mkTuple ["xkb" "de+neo_qwertz"])];
      };

      "org/gnome/desktop/wm/preferences".resize-with-right-button = true;

      "org/gnome/desktop/wm/keybindings" = {
        close = ["<Shift><Super>q"];
        minimize = [];
        move-to-monitor-left = ["<Shift><Control><Super>h"];
        move-to-monitor-right = ["<Shift><Control><Super>l"];
        move-to-workspace-1 = ["<Shift><Super>1"];
        move-to-workspace-2 = ["<Shift><Super>2"];
        move-to-workspace-3 = ["<Shift><Super>3"];
        move-to-workspace-4 = ["<Shift><Super>4"];
        switch-to-workspace-1 = ["<Super>1"];
        switch-to-workspace-2 = ["<Super>2"];
        switch-to-workspace-3 = ["<Super>3"];
        switch-to-workspace-4 = ["<Super>4"];
        toggle-fullscreen = ["<Super>f"];
      };

      "org/gnome/shell".enabled-extensions = [ "appindicatorsupport@rgcjonas.gmail.com" ];

      "org/gnome/shell/keybindings" = {
        show-screenshot-ui = ["<Shift><Super>s"];
        switch-to-application-1 = [];
        switch-to-application-2 = [];
        switch-to-application-3 = [];
        switch-to-application-4 = [];
      };

      # Desktop-shaped defaults: a machine on mains has no reason to blank or
      # suspend itself. Hosts on a battery override these.
      "org/gnome/desktop/session".idle-delay = lib.mkDefault (mkUint32 0);
      "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = lib.mkDefault "nothing";
      "org/gnome/desktop/peripherals/mouse".accel-profile = "flat";

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        ];
        screensaver = lib.mkDefault [];
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

    };
  };
}
