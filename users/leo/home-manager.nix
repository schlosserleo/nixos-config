{ inputs, ... }:
{ pkgs, ... }:

let
  shellAliases = {
    ga = "git add";
    gc = "git commit";
  };
in
{
  home = {
    stateVersion = "25.11";
    xdg.enable = true;
    packages = with pkgs; [
      eza
      fd
      fzf
      ripgrep
      chromium
      ghostty
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
}
