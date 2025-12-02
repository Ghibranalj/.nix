{ config, lib, pkgs, upkgs, prevpkgs, ... }:

{
  options = with lib; { dev.enable = mkEnableOption "enables gnome"; };
  config = lib.mkIf config.dev.enable {
    nixpkgs.config.permittedInsecurePackages = [ "beekeeper-studio-5.3.4" ];

    # playwright
    system.activationScripts.google-chrome-symlink = {
      text = ''
        mkdir -p /opt/google/chrome
        ln -sf ${pkgs.google-chrome}/bin/google-chrome-stable /opt/google/chrome/chrome
      '';
    };

    services.lorri.enable = true; # speeds up direnv for emacs
    environment.systemPackages = with pkgs; [
      direnv
      ## Compilers
      go
      gcc
      gnumake
      # rustup
      python3
      texliveSmall
      jdk
      nodejs
      bun
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
      upkgs.copilot-language-server
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

      upkgs.claude-code
      (writeScriptBin "glm" ''
        #!/usr/bin/env bash
        ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic \
        ANTHROPIC_AUTH_TOKEN="$GLM_AUTH_TOKEN" \
        ${upkgs.claude-code}/bin/claude --model glm-4.6 "$@"
      '')
      upkgs.codex
    ];
  };
}
