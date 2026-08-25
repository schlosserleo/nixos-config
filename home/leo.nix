{ pkgs, ... }:
{
  imports = [
    ./console.nix
    ./dconf.nix
  ];

  home = {
    stateVersion = "26.05";
    packages = with pkgs; [
      claude-code
			fastfetch
			ripgrep
			helium
			tutanota-desktop
    ];
  };

  xdg = {
    enable = true;
    terminal-exec = {
      enable = true;
      settings.default = [ "org.gnome.Console.desktop" ];
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/mailto" = "tutanota-desktop.desktop";
        "x-scheme-handler/tuta" = "tutanota-desktop.desktop";
        "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
      };
    };

    # Tuta writes this file itself on startup with Exec= pointing at the raw
    # extracted AppImage binary, which cannot run on NixOS. ~/.local/share
    # outranks /etc/profiles in XDG_DATA_DIRS, so that copy shadows the
    # packaged entry and breaks mailto. Pin it to the package's own entry.
    dataFile."applications/tutanota-desktop.desktop".source =
      "${pkgs.tutanota-desktop}/share/applications/tutanota-desktop.desktop";

    # Keep Tuta running in the tray so its push connection stays up and new
    # mail raises a notification. -a starts it hidden.
    configFile."autostart/tutanota-desktop.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Tuta Mail
      Comment=Tuta Mail background service
      Exec=${pkgs.tutanota-desktop}/bin/tutanota-desktop -a
      Icon=tutanota-desktop
      Terminal=false
      StartupNotify=false
      X-GNOME-Autostart-enabled=true
    '';
  };

  services = {
    gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-gnome3;
      extraConfig = ''
        allow-loopback-pinentry
      '';
    };
  };

  programs = {
    starship = {
      enable = true;
      presets = [ "no-nerd-font" ];
      enableFishIntegration = true;
      enableTransience = true;
      settings.add_newline = false;
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
      '';
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "Leo Schlosser";
          email = "leoschlosser@tutamail.com";
        };
        color.ui = true;
        init.defaultBranch = "main";
        core.editor = "nvim";
        pull.rebase = true;
      };
      signing = {
        key = "3FBCCD34E0CB2CE67A71B241F7155193AF248B6A";
        signByDefault = true;
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      extraPackages = with pkgs; [
        nixd
        nixfmt
        lua-language-server
      ];
      sideloadInitLua = true;
    };

    gpg = {
      enable = true;
      publicKeys = [
        {
          source = ./gpgpub.key;
          trust = "ultimate";
        }
      ];
      scdaemonSettings = {
        disable-ccid = true;
        pcsc-shared = true;
      };
    };
  };
}
