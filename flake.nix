{
  description = "multi-host nixos config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # CachyOS kernel & friends. Deliberately NOT following our nixpkgs:
    # chaotic's binary cache is built against *its own* pinned nixpkgs, and a
    # `follows` here would change every hash and force a full kernel compile.
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      chaotic,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      user = "leo";

      hosts = builtins.attrNames (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts)
      );

      mkHost =
        hostname:
        lib.nixosSystem {
          specialArgs = { inherit inputs user; };
          modules = [
            ./hosts/${hostname}
            ./modules/common.nix
            { networking.hostName = lib.mkDefault hostname; }
            chaotic.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs user; };
                users.${user} = import ./home/${user}.nix;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = lib.genAttrs hosts mkHost;
    };
}
