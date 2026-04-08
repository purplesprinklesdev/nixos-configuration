{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, stylix, ... }@inputs: {
    nixosConfigurations.desktop-nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { 
	inherit inputs;
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
	inherit inputs;
      };
      modules = [
        ./hosts/laptop/configuration.nix
        inputs.home-manager.nixosModules.default 
        stylix.nixosModules.stylix
      ];
    };
  };
}
