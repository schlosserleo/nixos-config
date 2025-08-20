{ nixpkgs, overlays, inputs }:

name: { system, user }:

let
  machineConfig = ../machines/${name}.nix;
  userOSConfig = ../users/${user}/nixos.nix;
  userHMConfig = ../users/${user}/home-manager.nix;

  systemFunc = nixpkgs.lib.nixosSystem;
  home-manager = inputs.home-manager.nixosModules.home-manager;
in
systemFunc rec {
  inherit system;

  modules = [
    {
      nixpkgs = {
        overlays = overlays;
        config.allowUnfree = true;
      };
    }

    machineConfig
    userOSConfig
    home-manager
    {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${user} = import userHMConfig { inputs = inputs; };
    }

    {
      config._module.args = {
        currentSystem = system;
        currentSystemName = name;
        currentSystemUser = user;
        inputs = inputs;
      };
    }
  ];
}
