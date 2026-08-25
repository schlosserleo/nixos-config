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
    ];
  };

  xdg = {
    enable = true;
    terminal-exec = {
      enable = true;
      settings.default = [ "org.gnome.Console.desktop" ];
    };
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
