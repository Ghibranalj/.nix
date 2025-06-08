{
  description = "Ghibran Jaringan";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url =
        "github:nix-community/home-manager/release-25.05"; # Match Nixpkgs version
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-doom-emacs-unstraightened.url =
      "github:marienz/nix-doom-emacs-unstraightened";
    grub2-themes = { url = "github:vinceliuice/grub2-themes"; };
    nix-colors.url = "github:misterio77/nix-colors";
    nixarr.url = "github:rasmus-kirk/nixarr";
    evdev-keymapper = {
      url = "github:kambi-ng/evdev-keymapper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self, nixpkgs, home-manager, nixpkgs-unstable, nixarr, ... }@inputs:
    let
      # Host generator function (thanks deepseek)
      mkHost = { hostName, system ? "x86_64-linux", hmEnabled ? true }:
        let
          upkgs = import nixpkgs-unstable {
            inherit system;
            config = {
              allowUnfree = true;
              permittedInsecurePackages = [ "*" ];
            };
          };

          host = { inherit hostName; };
        in nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs host nixarr upkgs; };
          modules = [
            ./sys
            (./hosts + "/${hostName}/hardware-configuration.nix")
            (./hosts + "/${hostName}/configuration.nix")
            inputs.grub2-themes.nixosModules.default
            inputs.evdev-keymapper.nixosModules.default
          ] ++ (if hmEnabled then [
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.extraSpecialArgs = { inherit inputs host; };
              home-manager.users.gibi = import ./home.nix;
            }
          ] else
            [ ]);
        };

      hosts = {
        server = mkHost { hostName = "server"; };
        vivo = mkHost { hostName = "vivo"; };
        pc = mkHost { hostName = "pc"; };
        tuf = mkHost { hostName = "tuf"; };
        media-server = mkHost {
          hostName = "media-server";
          hmEnabled = false;
        };
      };

    in { nixosConfigurations = hosts; };
}
