{ config, lib, pkgs, ... }: {
  options = with lib; { neovim.enable = mkEnableOption "enable neovim"; };

  config = lib.mkIf config.neovim.enable {
    programs.neovim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        material-nvim
        vim-suda
        # render-markdown-nvim
        lightline-vim
        vim-fugitive
        nvim-treesitter.withAllGrammars
        plenary-nvim
        telescope-nvim
        telescope-fzf-native-nvim
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        luasnip
        cmp_luasnip
        oil-nvim
        snacks-nvim
        claudecode-nvim
      ];
      extraPackages = with pkgs; [
        gopls
        clang-tools
        bash-language-server
        ripgrep
        fd
        wl-clipboard  # For clipboard support in Wayland
      ];
      extraLuaConfig = ''
        require('material').setup()
        vim.g.material_style = "darker"
        vim.cmd 'colorscheme material'
        vim.cmd 'set number relativenumber'
        vim.opt.clipboard = "unnamedplus"  -- Use system clipboard
        require'nvim-treesitter.configs'.setup {
            parser_install_dir = vim.fn.stdpath('cache') .. '/treesitter',
            ensure_installed = { "c", "bash", "nix", "markdown", "markdown_inline", "go" },
        }

        -- LSP configuration (Neovim 0.11+ API)
        vim.lsp.config('gopls', { cmd = { 'gopls' } })
        vim.lsp.config('clangd', { cmd = { 'clangd' } })
        vim.lsp.config('bashls', { cmd = { 'bash-language-server', 'start' } })
        vim.lsp.enable('gopls', 'clangd', 'bashls')

        -- Telescope configuration
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<space><space>', builtin.find_files, { desc = 'Find files' })
        vim.keymap.set('n', '<space>sp', builtin.live_grep, { desc = 'Search in directory' })
        vim.keymap.set('n', '<space>ss', builtin.current_buffer_fuzzy_find, { desc = 'Search in buffer' })
        vim.keymap.set('n', '<space>,', builtin.buffers, { desc = 'Switch buffers' })

        -- Oil configuration
        require('oil').setup {
          keymaps = {
            ["<CR>"] = "actions.select",
            ["l"] = "actions.select",
            ["h"] = "actions.parent",
          },
        }
        vim.keymap.set('n', '<space>o/', '<cmd>Oil<CR>', { desc = 'Open Oil' })

        -- Window splits
        vim.keymap.set('n', '<space>wv', '<C-w>v', { desc = 'Vertical split' })
        vim.keymap.set('n', '<space>ws', '<C-w>s', { desc = 'Horizontal split' })
        vim.keymap.set('n', '<space>wd', '<C-w>c', { desc = 'Delete current split' })

        -- Window navigation
        vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left split' })
        vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom split' })
        vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top split' })
        vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right split' })

        -- Terminal
        local term_buf = nil
        vim.keymap.set('n', '<space>ot', function()
          -- Check if terminal buffer exists and is valid
          if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
            -- Find windows containing this buffer
            local wins = vim.fn.win_findbuf(term_buf)
            if #wins > 0 then
              -- Terminal is open in a window, jump to it
              vim.fn.win_gotoid(wins[1])
            else
              -- Terminal exists but not visible, open it in bottom split
              vim.cmd('botright split | resize 12 | b ' .. term_buf)
            end
          else
            -- Create new terminal
            vim.cmd('botright split | resize 12 | terminal')
            term_buf = vim.api.nvim_get_current_buf()
            vim.api.nvim_buf_set_name(term_buf, 'terminal (bottom)')
          end
        end, { desc = 'Toggle terminal at bottom' })
        vim.keymap.set('n', '<space>oT', '<cmd>terminal<CR>', { desc = 'Open terminal' })
        vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

        -- Buffer navigation
        vim.keymap.set('n', '<space>bp', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
        vim.keymap.set('n', '<space>bn', '<cmd>bnext<CR>', { desc = 'Next buffer' })

        -- Claude Code (no terminal, WebSocket server only)
        require('claudecode').setup {
          terminal = {
            provider = 'none'  -- We launch glm manually
          }
        }
        vim.keymap.set('n', '<space>va', '<cmd>ClaudeCodeDiffAccept<CR>', { desc = 'Accept diff' })
        vim.keymap.set('n', '<space>vd', '<cmd>ClaudeCodeDiffDeny<CR>', { desc = 'Deny diff' })

        -- nvim-cmp configuration
        local cmp = require('cmp')
        cmp.setup {
          sources = {
            { name = 'nvim_lsp' },
            { name = 'buffer' },
            { name = 'path' },
          },
          mapping = cmp.mapping.preset.insert({
            ['<CR>'] = cmp.mapping.confirm({ select = false }),
            ['<Tab>'] = cmp.mapping.select_next_item(),
            ['<S-Tab>'] = cmp.mapping.select_prev_item(),
          }),
        }
      '';
    };
  };
}
