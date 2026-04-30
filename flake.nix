{
  description = "NixOS from Scratch";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
        modules = [
          ./machines/twinkdesk.nix
          {
            nixpkgs.overlays = [
              # inputs.neovim-nightly-overlay.overlays.default
              inputs.nix-cachyos-kernel.overlays.default
              # Skip deno tests (transitive dep of nix-cachyos-kernel, takes forever to build):
              # (final: prev: { deno = prev.deno.overrideAttrs (_: { doCheck = false; }); })
            ];
          }

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
