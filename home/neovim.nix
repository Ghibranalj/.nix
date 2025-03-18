{ config, lib, pkgs, ... }:

{
  options = with lib; {
    neovim.enable = mkEnableOption "enable neovim";
  };
  
  config = lib.mkIf config.neovim.enable {
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
  };
}
