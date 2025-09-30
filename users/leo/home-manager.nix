{ ... }:
{ pkgs, ... }:
let
  shellAliases = {
    ga = "git add";
    gc = "git commit";
    ls = "eza --icons";
  };
in
{
  imports = [
    ../../modules/dconf.nix
  ];
  xdg = {
    enable = true;
    terminal-exec = {
      enable = true;
      settings.default = [ "ghostty.desktop" ];
    };
    portal = {
      enable = true;
      configPackages = with pkgs; [
        xdg-desktop-portal-gtk
      ];
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
  };
  home = {
    stateVersion = "25.11";
    packages = with pkgs; [
      eza
      fd
      fzf
      tealdeer
      ripgrep
      chromium
      nautilus
      gnome-tweaks
      fastfetch
      yubioath-flutter
      (wrapFirefox (firefox-unwrapped.override { pipewireSupport = true; }) { })
      prismlauncher
      graalvmPackages.graalvm-oracle
      teamspeak6-client
    ];
    sessionVariables = {
      EDITOR = "nvim";
    };
    shell = {
      enableFishIntegration = true; 
    };
  };
  programs = {
    ghostty = {
      enable = true;
      enableFishIntegration = true;
      installVimSyntax = true;
      settings = {
        gtk-titlebar = false;
        theme = "light:GitHub Light Colorblind,dark:GitHub Dark Colorblind";
        font-family = "TX-02";
        font-style = "SemiCondensed";
        font-style-bold = "Bold SemiCondensed";
        font-style-italic = "SemiCondensed Oblique";
        font-style-bold-italic = "Bold SemiCondensed Oblique";
        font-feature = "-calt";
        font-size = 14;
      };
      themes = {
        moonfly = {
          background = "#080808";
          foreground = "#bdbdbd";
          selection-background = "#b2ceee";
          selection-foreground = "#080808";
          cursor-color = "#8e8e8e";
          palette = [
            "0=#323437"
            "1=#ff5d5d"
            "2=#8cc85f"
            "3=#e3c78a"
            "4=#80a0ff"
            "5=#cf87e8"
            "6=#79dac8"
            "7=#c6c6c6"
            "8=#949494"
            "9=#ff5189"
            "10=#36c692"
            "11=#c6c684"
            "12=#74b2ff"
            "13=#ae81ff"
            "14=#85dc85"
            "15=#e4e4e4"
          ];
        };
      };
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
    starship = {
      enableTransience = true;
      enableInteractive = true;
      enableFishIntegration = true;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      extraPackages = with pkgs; [
        lua-language-server
        nixd
        nixfmt
        stylua
      ];
      extraLuaConfig = ''
         vim.opt.number = true
         vim.opt.relativenumber = true
         vim.opt.termguicolors = true
         vim.opt.tabstop = 2
         vim.opt.softtabstop = 2
         vim.opt.shiftwidth = 2
         vim.opt.expandtab = true
         vim.opt.syntax = on
         vim.opt.foldlevel = 99
         vim.opt.colorcolumn = "100"
         vim.opt.scrolloff = 8
         vim.opt.signcolumn = "yes"
         vim.opt.splitbelow = true
         vim.opt.splitright = true
         vim.opt.undofile = true
         vim.opt.wrap = false

         vim.g.mapleader = " "

         vim.pack.add({
           { src = "https://github.com/neovim/nvim-lspconfig" },
           { src = "https://github.com/projekt0n/github-nvim-theme" },
           { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
           { src = "https://github.com/echasnovski/mini.pick" },
           { src = "https://github.com/nvim-tree/nvim-tree.lua"},
         })

         require("nvim-tree").setup()
         require("mini.pick").setup()
         require("lspconfig").nixd.setup({
         settings = {
             nixd = {
               formatting = {
                 command = { "nixfmt" },
               },
             },
           },
         })

         vim.lsp.enable({
           "lua_ls",
           "nil_ls",
         })

         vim.api.nvim_create_autocmd("FileType", {
           pattern = "lua",
           callback = function()
             vim.bo.formatprg = "stylua --indent-type Spaces --indent-width 2 -"
           end,
         })

         vim.api.nvim_create_autocmd("OptionSet", {
         pattern = "background",
         callback = function()
           if vim.o.background == "dark" then
             vim.cmd.colorscheme("github_dark_colorblind")
           else
             vim.cmd.colorscheme("github_light_colorblind")
           end
         end
        })

        vim.keymap.set("n", "<leader>ff", ":Pick files<CR>")
        vim.keymap.set("n", "<leader>fw", ":Pick grep_live<CR>")
        vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
        vim.keymap.set("n", "<leader>lf", ":lua vim.lsp.buf.format()<CR>")
      '';
    };
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
}
