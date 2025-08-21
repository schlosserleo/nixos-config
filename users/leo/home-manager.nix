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
    ];
    sessionVariables = {
      EDITOR = "nvim";
    };
  };
  programs = {
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
      extraConfig = {
        color.ui = true;
        github.user = "schlosserleo";
        init.defaultBranch = "main";
      };
    };
  };

  services = {
    gpg-agent = {
      enable = true;
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
