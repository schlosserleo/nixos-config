{
  description = "Leos Nix Conf";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
  };
  outputs =
    { nixpkgs, home-manager, ... }@inputs:
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
        system = "znver4";
        user = "leo";
      };
    };
}
