{ config, pkgs, lib, inputs, host, ... }:

{
  imports = [ inputs.nix-doom-emacs-unstraightened.hmModule ];

  home = {
    username = "gibi";
    homeDirectory = "/home/gibi";
    stateVersion = "24.11";

    file.".bashrc".source = lib.mkForce (
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.nix/home/.bashrc"
    );

    sessionVariables = {
      GUI = if host.isGui then "TRUE" else "FALSE";
    }; 

    file.".config/git-prompt.sh".source = "${pkgs.git}/share/git/contrib/completion/git-prompt.sh";
  };

  programs.bash = {
    enable = true;
    profileExtra = ''
    alias nix-rebuild="sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/.nix#${host.hostName}"
    alias nix-update="sudo nix-channel --update && nix-rebuild"
    alias nix-cleanup="sudo nix-collect-garbage -d"
    '';
  };

  programs.git = {
    enable = true;
    userName = "Ghibranalj";
    userEmail = "24712554+Ghibranalj@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "master";
    };
  };

  programs.doom-emacs = {
    enable = true;
    doomDir = ./home/doom;
    provideEmacs = true;
    experimentalFetchTree= true;

    extraPackages = (ps: with ps; [
      tree-sitter tree-sitter-langs treesit-grammars.with-all-grammars
      inputs.templ-ts-mode.packages.${host.system}.templ-mode-emacs
      inputs.templ-ts-mode.packages.${host.system}.templ-grammar
    ]);
  };

  programs.home-manager.enable = true;

  systemd.user.services.emacs = let
    emacs-server = if host.isGui then "server" else "term";
    in {
      Unit = {
        Description = "Emacs text editor";
        Documentation = [ "info:emacs" "man:emacs(1)" "https://gnu.org/software/emacs/" ];
      };
      Service = {
        Type = "notify";
        ExecStart = "${config.home.profileDirectory}/bin/emacs --fg-daemon=${emacs-server}";
        ExecStop = "${pkgs.emacs}/bin/emacsclient -s ${emacs-server} --eval '(kill-emacs)'";
        Environment = lib.mkForce [
          "PATH=/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${config.home.profileDirectory}/bin"
        ];
        Restart = "always";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      material-nvim
      vim-suda
      nvim-treesitter
    ]; 
    extraLuaConfig = ''
      require('material').setup()
      vim.g.material_style = "darker"
      vim.cmd 'colorscheme material'
      vim.cmd 'set number relativenumber'
      require'nvim-treesitter.configs'.setup {
        ensure_installed = { "c", "bash", "nix", "markdown", "markdown_inline" },
      }
    '';
  };
}
