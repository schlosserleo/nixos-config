{ pkgs, inputs, ... }:
{
  home = {
    stateVersion = "26.05";
    packages = with pkgs; [
      claude-code
    ];
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
        claude-code
      ];
      sideloadInitLua = true;
    };
    gpg = {
      enable = true;
      homedir = "/home/leo/.gnupg";
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
