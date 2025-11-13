{
  description = "Ghibran Jaringan";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-prev.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url =
        "github:nix-community/home-manager/release-25.05"; # Match Nixpkgs version
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.doomemacs.url =
        "github:doomemacs/doomemacs/5e7e93beb9f2b5a81768aaf4950203ceea21c4f6"; # 8 October 2025
    };
    grub2-themes = { url = "github:vinceliuice/grub2-themes"; };
    nixarr.url = "github:rasmus-kirk/nixarr";
    evdev-keymapper = {
      url = "github:kambi-ng/evdev-keymapper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, home-manager, nixpkgs-unstable, nixarr
    , nixpkgs-prev, split-monitor-workspaces, hyprland, stylix, ... }@inputs:
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
          prevpkgs = import nixpkgs-prev {
            inherit system;
            config = {
              allowUnfree = true;
              permittedInsecurePackages = [ "*" ];
            };
          };

          host = { inherit hostName; };
        in nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs host nixarr upkgs prevpkgs split-monitor-workspaces;
          };
          modules = [
            ./sys
            (./hosts + "/${hostName}/hardware-configuration.nix")
            (./hosts + "/${hostName}/configuration.nix")
            inputs.grub2-themes.nixosModules.default
            inputs.evdev-keymapper.nixosModules.default
            inputs.nix-index-database.nixosModules.nix-index
          ] ++ (if hmEnabled then [
            home-manager.nixosModules.home-manager
            {
              home-manager.sharedModules = [
                stylix.homeModules.stylix
                inputs.nix-index-database.homeModules.nix-index
              ];
              home-manager.useGlobalPkgs = true;
              home-manager.backupFileExtension = "bak";
              home-manager.extraSpecialArgs = {
                inherit inputs host split-monitor-workspaces hyprland;
              };
              home-manager.users.gibi = import ./home.nix;
            }
          ] else
            [ ]);
        };

      hosts = {
        server = mkHost { hostName = "server"; };
        vivo = mkHost { hostName = "vivo"; };
        advan = mkHost { hostName = "advan"; };
        pc = mkHost { hostName = "pc"; };
        tuf = mkHost { hostName = "tuf"; };
        media-server = mkHost {
          hostName = "media-server";
          hmEnabled = false;
        };
      };

    in { nixosConfigurations = hosts; };
}
