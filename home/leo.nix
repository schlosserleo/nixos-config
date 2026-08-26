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
      signal-desktop
      yubioath-flutter
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

    # Tuta writes its own entry at startup pointing at the unpacked AppImage,
    # and ~/.local/share shadows the packaged one, breaking mailto.
    dataFile."applications/tutanota-desktop.desktop".source =
      "${pkgs.tutanota-desktop}/share/applications/tutanota-desktop.desktop";

    # -a starts it hidden.
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
      presets = [ "nerd-font-symbols" ];
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
        # nvim-treesitter builds parsers with these.
        tree-sitter
        gcc
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
