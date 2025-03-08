{
  description = "Ghibran Jaringan";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, home-manager }: let
    # Host generator function (thanks deepseek)
    mkHost = { hostName, system ? "x86_64-linux", hmEnabled ? true }: 
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          (./hosts + "/${hostName}/hardware-configuration.nix")
          (./hosts + "/${hostName}/configuration.nix")
          ./configuration.nix  # Base config for all hosts
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.users.gibi = 
              if hmEnabled
              then import ./home.nix
              else {};
          }
        ];
      };

    # Define all your hosts
    hosts = {
      laptop = mkHost { hostName = "laptop"; };
      pc = mkHost { hostName = "pc"; };
      server = mkHost { 
        hostName = "server";
      };
    };

  in {
    nixosConfigurations = hosts;
  };
}
