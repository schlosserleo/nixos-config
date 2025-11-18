{ pkgs, ... }:
{
  imports = [
    ../modules/dconf.nix
  ];
  home = {
    stateVersion = "25.11";
    packages = with pkgs; [
      gnome-console
      fastfetch
      (wrapFirefox (firefox-unwrapped.override { pipewireSupport = true; }) { })
      yubioath-flutter
      maple-mono.NF
      signal-desktop
    ];
  };
  xdg = {
    enable = true;
    terminal-exec.enable = true;
    configFile."nvim" = {
      source = ./config/neovim-config;
      recursive = true;
    };
  };
  programs = {
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
      defaultEditor = true;
      extraPackages = with pkgs; [
        nixd
        lua-language-server
        nixfmt
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
    gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-gnome3;
      extraConfig = ''
        allow-loopback-pinentry
      '';
    };
  };
}
