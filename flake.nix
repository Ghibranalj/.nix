{
  description = "Ghibran Jaringan";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url =
        "github:nix-community/home-manager/release-24.11"; # Match Nixpkgs version
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
  outputs = { self, nixpkgs, home-manager, nixpkgs-unstable, ... }@inputs:
    let
      # Host generator function (thanks deepseek)
      mkHost = { hostName, system ? "x86_64-linux", hmEnabled ? true }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (final: prev: {
                upkgs = import nixpkgs-unstable {
                  inherit system;
                  config.allowUnfree = true;
                };
              })
            ];
            config.allowUnfree = true;
          };
          host = { inherit hostName; };
        in nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs host pkgs; };
          modules = [
            ./sys
            (./hosts + "/${hostName}/hardware-configuration.nix")
            (./hosts + "/${hostName}/configuration.nix")
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.extraSpecialArgs = { inherit inputs host; };
              home-manager.users.gibi =
                if hmEnabled then import ./home.nix else { };
            }
            inputs.grub2-themes.nixosModules.default
            inputs.evdev-keymapper.nixosModules.default
          ];
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
