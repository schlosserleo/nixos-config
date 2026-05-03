{
  description = "NixOS from Scratch";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    self = {
      submodules = true;
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: {
    nixosConfigurations = {
      vm = nixpkgs.lib.nixosSystem {
        modules = [
          ./machines/vm.nix
          {
            # nixpkgs.overlays = [
            #   inputs.neovim-nightly-overlay.overlays.default
            # ];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit inputs;};
              users.leo = import ./home/vm.nix;
            };
          }
        ];
      };
      twinkdesk = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./machines/twinkdesk.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit inputs;};
              users.leo = import ./home/twinkdesk.nix;
            };
          }
        ];
      };

      twinkpad = nixpkgs.lib.nixosSystem {
        modules = [
          ./machines/twinkpad.nix
          {
            # nixpkgs.overlays = [
            #   inputs.neovim-nightly-overlay.overlays.default
            # ];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit inputs;};
              users.leo = import ./home/twinkpad.nix;
            };
          }
        ];
      };
    };
  };
}
