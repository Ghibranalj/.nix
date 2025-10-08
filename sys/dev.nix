{ config, lib, pkgs, upkgs, prevpkgs, ... }:

{
  options = with lib; { dev.enable = mkEnableOption "enables gnome"; };
  config = lib.mkIf config.dev.enable {
    nixpkgs.config.permittedInsecurePackages =
      [ "beekeeper-studio-5.1.5" "libsoup-2.74.3" ];

    services.lorri.enable = true; # speeds up direnv for emacs
    environment.systemPackages = with pkgs; [
      direnv
      ## Compilers
      go
      gcc
      gnumake
      rustup
      python3
      texliveSmall
      jdk
      nodejs
      zig

      ## LSP
      gopls
      ccls
      nixd
      eslint
      yaml-language-server
      jdt-language-server
      lua-language-server
      typescript-language-server
      gocode-gomod
      upkgs.templ
      emmet-ls
      sqls
      rustywind
      upkgs.copilot-language-server-fhs
      typescript-language-server
      astro-language-server

      ## DB stuff
      beekeeper-studio

      # formatters
      nixfmt-classic
      nodePackages.prettier

      httpie-desktop
      httpie

      #reverse engineering
      ghidra-bin

      #eww
      upkgs.code-cursor

      #devenv
      upkgs.devenv

      claude-code
    ];
  };
}
