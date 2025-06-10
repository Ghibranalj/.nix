{ config, pkgs, lib, inputs, host, ... }:

{
  _module.args = { inherit inputs host; };

  imports = [
    inputs.nix-doom-emacs-unstraightened.hmModule
    inputs.nix-colors.homeManagerModules.default
    ./home
    (./hosts + "/${host.hostName}/home.nix")
  ];

}
