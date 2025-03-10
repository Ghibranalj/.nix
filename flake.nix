{
  description = "Ghibran Jaringan";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11"; # Match Nixpkgs version
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
  };
  outputs = { self, nixpkgs, home-manager, nix-doom-emacs-unstraightened }: let
    # Host generator function (thanks deepseek)
    mkHost = { hostName, system ? "x86_64-linux", hmEnabled ? true, gui ? true, dev ? true }: 
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit gui dev; };
        modules = [
          (./hosts + "/${hostName}/hardware-configuration.nix")
          (./hosts + "/${hostName}/configuration.nix")
          ./configuration.nix  # Base config for all hosts
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
	    home-manager.extraSpecialArgs = { inherit nix-doom-emacs-unstraightened gui; };
            home-manager.users.gibi = 
              if hmEnabled
              then import ./home.nix
              else {};
          }
        ];
      };

    # Define all your hosts
    hosts = {
      server = mkHost { 
        hostName = "server";
	      gui = false;
      };
    };

  in {
    nixosConfigurations = hosts;
  };
}
