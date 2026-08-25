{
  description = "multi-host nixos config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      chaotic,
      disko,
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
            disko.nixosModules.disko
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
