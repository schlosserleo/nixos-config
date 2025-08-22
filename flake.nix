{
  description = "Leos Nix Conf";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:MarceColl/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self, nixpkgs, home-manager, ... }@inputs:
    let
      overlays = [
        inputs.neovim-nightly-overlay.overlays.default
      ];

      mkSystem = import ./lib/mksystem.nix {
        inherit overlays nixpkgs inputs;
      };
    in
    {
      nixosConfigurations.vm = mkSystem "vm" {
        system = "x86_64-linux";
        user = "leo";
      };
      nixosConfigurations.vm2 = mkSystem "vm2" {
        system = "x86_64-linux";
        user = "leo";
      };
      nixosConfigurations.twinkpad = mkSystem "twinkpad" {
        system = "x86_64-linux";
        user = "leo";
      };
    };
}
