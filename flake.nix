{
  description = "Ghibran Jaringan";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11"; # Match Nixpkgs version
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
    grub2-themes = {
      url = "github:vinceliuice/grub2-themes";
    };
    nix-colors.url = "github:misterio77/nix-colors";
  };
  outputs = { self, nixpkgs, home-manager, ... } @ inputs : let
    # Host generator function (thanks deepseek)
    mkHost =
      { hostName, system ? "x86_64-linux", hmEnabled ? true, isGui ? true, dev ? true,
        X11 ? true}:
      let
        host = {
          inherit hostName isGui dev X11;
        }; 
      in
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs host; };
        modules = [
          (./hosts + "/${hostName}/hardware-configuration.nix")
          (./hosts + "/${hostName}/configuration.nix")
          ./configuration.nix  # Base config for all hosts
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.extraSpecialArgs = { inherit inputs host; };
            home-manager.users.gibi = 
              if hmEnabled
              then import ./home.nix
              else {};
          }
          inputs.grub2-themes.nixosModules.default
        ];
      };

    # Define all your hosts
    hosts = {
      server = mkHost { 
        hostName = "server";
        isGui = false;
      };
      vivo = mkHost {
      	hostName = "vivo";
        isGui = true;
        X11 = false;
      };
    };

  in {
    nixosConfigurations = hosts;
  };
}
