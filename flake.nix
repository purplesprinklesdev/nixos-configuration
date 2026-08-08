{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-26.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, stylix, ... }@inputs: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    unstable = import inputs.unstable { inherit system; };
  in 
  {
    nixosConfigurations.desktop-nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { 
	inherit inputs unstable;
      };
      modules = [
        ./hosts/desktop/configuration.nix
        ./hosts/desktop/gaming.nix
        inputs.home-manager.nixosModules.default 
        stylix.nixosModules.stylix
      ];
    };
    nixosConfigurations.laptop-nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { 
	inherit inputs unstable;
      };
      modules = [
        ./hosts/laptop/configuration.nix
        inputs.home-manager.nixosModules.default 
        stylix.nixosModules.stylix
      ];
    };
  };
}
