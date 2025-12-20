{
  description = "NixOS from Scratch";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-master";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-master";
    };
    self = {
      submodules = true;
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        vm = nixpkgs.lib.nixosSystem {
          modules = [
            ./machines/vm.nix
            {
              nixpkgs.overlays = [
                inputs.neovim-nightly-overlay.overlays.default
              ];
            }
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.leo = import ./home/vm.nix;
              };
            }
          ];
        };
        twinkdesk = nixpkgs.lib.nixosSystem {
          modules = [
            ./machines/twinkdesk.nix
            {

              nixpkgs.overlays = [
                inputs.neovim-nightly-overlay.overlays.default
              ];
            }

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.leo = import ./home/twinkdesk.nix;
              };
            }
          ];
        };

        twinkpad = nixpkgs.lib.nixosSystem {
          modules = [
            ./machines/twinkpad.nix
            {
              nixpkgs.overlays = [
                inputs.neovim-nightly-overlay.overlays.default
              ];
            }
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.leo = import ./home/twinkpad.nix;
              };
            }
          ];
        };
      };
    };
}
