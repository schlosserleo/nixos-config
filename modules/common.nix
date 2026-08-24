{ pkgs, user, ... }:
{
	imports = [
		./gnome.nix
	];

	console.keyMap = "neoqwertz";
	time.timeZone = "Europe/Berlin";

	boot = {
		tmp.cleanOnBoot = true;
		loader = {
			systemd-boot.enable = true;
			efi.canTouchEfiVariables = true;
		};
	};

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh = {
      authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCkmeY0m0zd1b+RBpHvBstipbDvBKyxzwFsijEmoqMc"
      ];
    };
    hashedPassword = "$y$j9T$7EjjIvchL56tLLlI5uU7E.$ZHcMPPUelBNnbGjSU0ZxILQWuizLcObrQg6rF.meM69";
  };

  users.users.root.hashedPassword = "$y$j9T$1TQe91H/nADAi30/Dzdaw.$3Pa5jiCTQ0ykK3iq0KZHDoeI50NddfN.VUdI32eCsM3";

	programs.fish.enable = true;

	services.pcscd.enable = true;

  environment.systemPackages = with pkgs; [
    git
    neovim
  ];
}
