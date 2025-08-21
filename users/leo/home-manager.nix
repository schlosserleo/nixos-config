{ inputs, ... }:
{ config, lib, pkgs, ... }:

let
  shellAliases = {
    ga = "git add";
    gc = "git commit";
    ls = "eza --icons";
  };
in
{
  xdg.enable = true;
  home = {
    stateVersion = "25.11";
    packages = with pkgs; [
      eza
      fd
      fzf
      tealdeer
      ripgrep
      chromium
      ghostty
      nautilus
      gnome-tweaks
      xdg-terminal-exec
      fastfetch
      yubioath-flutter
    ];
    sessionVariables = {
      EDITOR = "nvim";
    };
  };
  programs = {
    gpg = {
      enable = true;
      homedir = "/home/leo/.gnupg";
      publicKeys = [ { 
        source = ./gpgpub.key; 
	trust = "ultimate";
      } ];
      scdaemonSettings = {
        disable-ccid = true;
	      pcsc-shared = true;
      };
    };
    bash = {
      enable = true;
      shellOptions = [ ];
      initExtra = builtins.readFile ./bashrc;
      shellAliases = shellAliases;
    };
    fish = {
      enable = true;
      shellAliases = shellAliases;
    };
    neovim.enable = true;
    git = {
      enable = true;
      userName = "Leo Schlosser";
      userEmail = "leoschlosser@tutamail.com";
      signing = {
	key = "F7155193AF248B6A";
	signByDefault = true;
      };
      extraConfig = {
        color.ui = true;
        github.user = "schlosserleo";
        init.defaultBranch = "main";
        core.editor = "nvim";
        commit.gpgsign = true;
        tag.gpgsign = true;
        pull.rebase = true;
      };
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      enableFishIntegration = true;
      pinentry.package = pkgs.pinentry-gnome3;
      extraConfig = ''
        allow-loopback-pinentry
      '';
    };
  };

  dconf.enable = true;
  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" "xwayland-native-scaling" ];
    };
    "org/gnome/desktop/input-sources" = {
      show-all-sources = true;
      sources = [ (lib.hm.gvariant.mkTuple [ "xkb" "de+neo_qwertz" ]) ];
    };
  };
}
