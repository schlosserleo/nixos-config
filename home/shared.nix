{ inputs, pkgs, ... }:

let
  shellAliases = {
    nixosrebuild = "sudo nixos-rebuild switch --flake";
  };
  prismlauncher-wrapped = pkgs.symlinkJoin {
    name = "prismlauncher-wrapped";
    paths = [ pkgs.prismlauncher ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      wrapProgram $out/bin/prismlauncher \
        --set XDG_DATA_DIRS "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    '';
  };
in
{
  imports = [
    ../modules/dconf.nix
  ];
  home = {
    stateVersion = "26.05";
    packages = with pkgs; [
      gnome-console
      fastfetch
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      yubioath-flutter
      nerd-fonts.fantasque-sans-mono
      signal-desktop
      prismlauncher-wrapped
      openjdk25
      tmux
      vlc
    ];
    sessionVariables = {
      EDITOR = "nvim";
    };
  };
  xdg = {
    enable = true;
    terminal-exec = {
      enable = true;
      settings.default = [ "com.mitchellh.ghostty.desktop" ];
    };
    configFile."nvim" = {
      source = ./config/neovim-config;
      recursive = true;
    };
  };
  programs = {
    ssh = {

      enable = true;
      enableDefaultConfig = false; # silences the warning
      matchBlocks."*" = {
        extraOptions = {
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
    };
    bash = {
      enable = true;
      shellAliases = shellAliases;
    };
    ghostty = {
      enable = true;
      installVimSyntax = true;
      settings = {
        theme = "light:GitHub Light Colorblind,dark:GitHub Dark Colorblind";
        font-family = "FantasqueSansM Nerd Font Mono";
        font-size = 13;
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
