{ config, pkgs, lib, inputs, host, ... }:

{
  imports = [
    inputs.nix-doom-emacs-unstraightened.hmModule
    inputs.nix-colors.homeManagerModules.default
    (./hosts + "/${host.hostName}/home.nix")
  ];

  colorScheme = inputs.nix-colors.colorSchemes.material-darker;

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

  };

  programs.bash = {
    enable = true;
    profileExtra = ''
    . ${pkgs.git}/share/git/contrib/completion/git-prompt.sh
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
  };

  systemd.user.services.emacs = let
    emacsServer = if host.isGui then "server" else "term";
    wantedBy = if host.isGui then "graphical-session" else "default";
    in {
      Unit = {
        Description = "Emacs text editor";
        Documentation = [ "info:emacs" "man:emacs(1)" "https://gnu.org/software/emacs/" ];
        After = lib.mkIf host.isGui [ "graphical-session.target" "default.target" ];
        Wants = lib.mkIf host.isGui [ "graphical-session.target" ];
      };
      Service = {
        Type = "notify";
        ExecStart = "${config.home.profileDirectory}/bin/emacs --fg-daemon=${emacsServer}";
        ExecStop = "${pkgs.emacs}/bin/emacsclient -s ${emacsServer} --eval '(kill-emacs)'";
        Environment = lib.mkForce [
          "PATH=/run/wrappers/bin:/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${config.home.profileDirectory}/bin:/run/"
        ];
        Restart = "always";
      };
      Install = {
        WantedBy = [ "${wantedBy}.target" ];
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

  programs.alacritty = lib.mkIf host.isGui {
    enable = true;
    settings = lib.importTOML ./home/alacritty.toml;
  };

  # xbindkeys
  home.file.".config/xbindkeys/xbindkeysrc".source = ./home/xbindkeysrc;

  systemd.user.services.xbindkeys = lib.mkIf (host.isGui && host.X11) {
    Unit = {
      Description = "xbindkeys";
      After = [ "graphical-session.target" "default.target" ];
      Wants = [ "graphical-session.target" ];
    };
    Service = {
      Type = "notify";
      ExecStart = "${pkgs.xbindkeys}/bin/xbindkeys -f ${config.home.homeDirectory}/.config/xbindkeys/xbindkeysrc --nodaemon";
      Environment = lib.mkForce [
        "PATH=/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${config.home.profileDirectory}/bin"
      ];
      Restart = "always";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # GTK
  gtk = lib.mkIf host.isGui {
    enable = true;
    theme = {
      name = config.colorScheme.slug;
      package = 
      let
        inherit
          (inputs.nix-colors.lib-contrib {inherit pkgs;})
          gtkThemeFromScheme
          ;
      in
        gtkThemeFromScheme {scheme = config.colorScheme;};
      };
  };

  programs.rofi = {
    enable = (! host.X11);
    package = pkgs.rofi; # (if host.X11 then pkgs.rofi else pkgs.rofi-wayland);
    configPath = "";
    plugins = [
        pkgs.rofi-calc
        pkgs.rofi-emoji
    ];
  };
  home.file.".config/rofi/config.rasi".source = ./home/config.rasi;
}
