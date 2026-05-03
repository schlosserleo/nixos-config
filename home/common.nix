{
  inputs,
  pkgs,
  lib,
  ...
}: let
  # prismlauncher launched outside GNOME doesn't see the schemas needed for file pickers etc.
  prismlauncher-wrapped = pkgs.symlinkJoin {
    name = "prismlauncher-wrapped";
    paths = [pkgs.prismlauncher];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/prismlauncher \
        --set XDG_DATA_DIRS "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    '';
  };
in {
  imports = [
    ../modules/home/dconf.nix
  ];

  home = {
    stateVersion = "26.05";
    # foot's theme.ini cannot be a Nix-store symlink because darkman rewrites it at runtime.
    activation.footThemeInit = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -f "$HOME/.config/foot/theme.ini" ]; then
        mkdir -p "$HOME/.config/foot"
        printf '[main]\ninitial-color-theme = dark\n' > "$HOME/.config/foot/theme.ini"
      fi
    '';
    packages = with pkgs; [
      gnome-console
      fastfetch
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
      yubioath-flutter
      signal-desktop
      prismlauncher-wrapped
      openjdk25
      tmux
      vlc
    ];
    sessionVariables.EDITOR = "nvim";
  };

  xdg = {
    enable = true;
    terminal-exec = {
      enable = true;
      settings.default = ["foot.desktop"];
    };
    configFile."nvim" = {
      source = ./config/neovim-config;
      recursive = true;
    };
  };

  programs = {
    foot = {
      enable = true;
      settings = {
        main = {
          font = "Cozette:size=8";
          shell = "fish --login --interactive";
          pad = "10x10 center";
          include = "~/.config/foot/theme.ini";
        };
        key-bindings.color-theme-toggle = "Control+Return";
        csd.preferred = "none";
        # GitHub Light Colorblind
        colors-light = {
          alpha = "0.9";
          background = "ffffff";
          foreground = "24292f";
          selection-background = "24292f";
          selection-foreground = "ffffff";
          cursor = "3c9cff 0969da";
          regular0 = "24292f";
          regular1 = "b35900";
          regular2 = "0550ae";
          regular3 = "4d2d00";
          regular4 = "0969da";
          regular5 = "8250df";
          regular6 = "1b7c83";
          regular7 = "6e7781";
          bright0 = "57606a";
          bright1 = "8a4600";
          bright2 = "0969da";
          bright3 = "633c01";
          bright4 = "218bff";
          bright5 = "a475f9";
          bright6 = "3192aa";
          bright7 = "8c959f";
        };
        # GitHub Dark Colorblind
        colors-dark = {
          alpha = "0.9";
          background = "0d1117";
          foreground = "c9d1d9";
          selection-background = "c9d1d9";
          selection-foreground = "0d1117";
          cursor = "98e6ff 58a6ff";
          regular0 = "484f58";
          regular1 = "ec8e2c";
          regular2 = "58a6ff";
          regular3 = "d29922";
          regular4 = "58a6ff";
          regular5 = "bc8cff";
          regular6 = "39c5cf";
          regular7 = "b1bac4";
          bright0 = "6e7681";
          bright1 = "fdac54";
          bright2 = "79c0ff";
          bright3 = "e3b341";
          bright4 = "79c0ff";
          bright5 = "d2a8ff";
          bright6 = "56d4dd";
          bright7 = "ffffff";
        };
      };
    };

    starship = {
      enable = true;
      presets = ["no-nerd-font"];
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

    bash = {
      enable = true;
      shellAliases.nixosrebuild = "sudo nixos-rebuild switch --flake";
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*".extraOptions = {
        KexAlgorithms = "sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512";
        Ciphers = "aes256-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-gcm@openssh.com,aes128-ctr";
        MACs = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com";
        RequiredRSASize = "3072";
        HostKeyAlgorithms = "sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256";
        CASignatureAlgorithms = "sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256";
        HostbasedAcceptedAlgorithms = "sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256";
        PubkeyAcceptedAlgorithms = "sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256";
      };
    };

    ghostty = {
      enable = true;
      installVimSyntax = true;
      settings = {
        command = "fish --login --interactive";
        theme = "light:GitHub Light Colorblind,dark:GitHub Dark Colorblind";
        font-family = "TX02 Nerd Font";
        font-style-bold = "Bold";
        font-style-italic = "Oblique";
        font-style-bold-italic = "Bold Oblique";
        font-size = 11;
      };
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
        key = "F7155193AF248B6A";
        signByDefault = true;
      };
    };

    neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      defaultEditor = true;
      extraPackages = with pkgs; [
        alejandra
        nixd
        lua-language-server
        ripgrep
      ];
    };

    gpg = {
      enable = true;
      homedir = "/home/leo/.gnupg";
      publicKeys = [
        {
          source = ./config/gpgpub.key;
          trust = "ultimate";
        }
      ];
      scdaemonSettings = {
        disable-ccid = true;
        pcsc-shared = true;
      };
    };
  };

  services = {
    darkman = {
      enable = true;
      settings = {
        lat = 52.518611;
        lng = 13.408333;
      };
      darkModeScripts = {
        gtk-theme = ''
          ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
        '';
        foot-theme = ''
          printf '[main]\ninitial-color-theme = dark\n' > "$HOME/.config/foot/theme.ini"
        '';
      };
      lightModeScripts = {
        gtk-theme = ''
          ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
        '';
        foot-theme = ''
          printf '[main]\ninitial-color-theme = light\n' > "$HOME/.config/foot/theme.ini"
        '';
      };
    };

    gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-gnome3;
      extraConfig = ''
        allow-loopback-pinentry
      '';
    };
  };
}
