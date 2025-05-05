{ config, lib, pkgs, ... }:

{
  
  options = with lib; {
     dev.enable = mkEnableOption "enables gnome";
  };

  config = lib.mkIf config.dev.enable {
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
    pnpm
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
    templ
    emmet-ls
    sqls
    rustywind
    upkgs.copilot-language-server-fhs

    ## DB stuff
    beekeeper-studio
    ];
  };
}
