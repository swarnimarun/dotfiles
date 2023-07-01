-- init.lua
-- using paq for the sake of package management

if vim.g.vscode then
    print "Running inside *vscode*"
    vim.keymap.set('n', 't', 'vt');
    vim.keymap.set('n', 'd', 'x');
    vim.keymap.set('n', 'x', 'V');
    vim.keymap.set('v', 'x', 'j');
    vim.keymap.set('v', 'j', '<esc>j');
    vim.keymap.set({'n', 'v'}, 'b', '<esc>vb');
    vim.keymap.set({'n', 'v'}, 'B', '<esc>vB');
    vim.keymap.set({'n', 'v'}, 'e', '<esc>ve');
    vim.keymap.set({'n', 'v'}, 'E', '<esc>vE');
    vim.keymap.set({'n', 'v'}, 'w', '<esc>vw');
    vim.keymap.set({'n', 'v'}, 'W', '<esc>vW');
    vim.keymap.set('v', 'h', '<esc>h');
    vim.keymap.set('v', 'k', '<esc>k');
    vim.keymap.set('v', 'l', '<esc>l');
    vim.keymap.set('n', 'm', 'v');
    vim.keymap.set('n', 'mim', 'vi(')
    vim.keymap.set('n', 'miM', 'vi{')
    vim.keymap.set('n', 'gh', 'g0');
    vim.keymap.set('n', 'gl', 'g$');
    return
end

require "paq" {
    "savq/paq-nvim", -- Let Paq manage itself

    "neovim/nvim-lspconfig",

    { "olimorris/onedarkpro.nvim", priority = 1000 }, -- Ensure it loads first

    { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' },

    {
        "willothy/nvim-cokeline",
        config = true
    },

    { 'numToStr/Comment.nvim', },

    { 'jose-elias-alvarez/typescript.nvim' },

    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-path' },

    { 'saadparwaiz1/cmp_luasnip' },

    { 'L3MON4D3/LuaSnip' },

    {
  	 "folke/which-key.nvim",
  	 event = "VeryLazy",
  	 init = function()
    	      vim.o.timeout = true
    	      vim.o.timeoutlen = 300
  	 end,
         opts = {
             -- your configuration comes here
         }
     }
}

vim.cmd("set number");
vim.cmd("set signcolumn=yes");
vim.cmd("colorscheme onedark_vivid");
vim.cmd("set tabstop=4");
vim.cmd("set shiftwidth=4");
vim.cmd("set expandtab");

require('Comment').setup()

local lspconfig = require('lspconfig')
local lsp_defaults = lspconfig.util.default_config
lsp_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lsp_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)
-- setup python language server
lspconfig.pyright.setup {}
-- setup typescript language server
require("typescript").setup({
    disable_commands = false, -- prevent the plugin from creating Vim commands
    debug = false, -- enable debug logging for commands
    go_to_source_definition = {
        fallback = true, -- fall back to standard LSP definition on failure
    },
    server = { -- pass options to lspconfig's setup method
        -- on_attach = ...,
        settings = {
        },
    },
})
-- use rust-analyzer as the language server
lspconfig.rust_analyzer.setup {
  -- Server-specific settings. See `:help lspconfig-setup`
  settings = {
    ['rust-analyzer'] = {},
  },
}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
-- vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
-- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
-- vim.api.nvim_create_autocmd('LspAttach', {
--   group = vim.api.nvim_create_augroup('UserLspConfig', {}),
--   callback = function(ev)
--     -- Enable completion triggered by <c-x><c-o>
--     vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
--
--     -- Buffer local mappings.
--     -- See `:help vim.lsp.*` for documentation on any of the below functions
--     local opts = { buffer = ev.buf }
--     vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
--     vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
--     vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
--     vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
--     vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
--     vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
--     vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
--     vim.keymap.set('n', '<space>wl', function()
--       print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
--     end, opts)
--     vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
--     vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
--     vim.keymap.set({ 'n', 'v' }, '<space>a', vim.lsp.buf.code_action, opts)
--     vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
--     vim.keymap.set('n', '<space>f', function()
--       vim.lsp.buf.format { async = true }
--     end, opts)
--   end,
-- })

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function()
    local bufmap = function(mode, lhs, rhs)
      local opts = {buffer = true}
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Displays hover information about the symbol under the cursor
    bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')

    -- Jump to the definition
    bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

    -- Jump to declaration
    bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

    -- Lists all the implementations for the symbol under the cursor
    bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

    -- Jumps to the definition of the type symbol
    bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

    -- Lists all the references 
    bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

    -- Displays a function's signature information
    bufmap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

    -- Renames all references to the symbol under the cursor
    bufmap('n', '<space>r', '<cmd>lua vim.lsp.buf.rename()<cr>')

    -- Selects a code action available at the current cursor position
    bufmap('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<cr>')
    bufmap('x', '<space>a', '<cmd>lua vim.lsp.buf.range_code_action()<cr>')

    -- Show diagnostics in a floating window
    bufmap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

    -- Move to the previous diagnostic
    bufmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')

    -- Move to the next diagnostic
    bufmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
  end
})

vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

require('luasnip.loaders.from_vscode').lazy_load()

local cmp = require('cmp')
local luasnip = require('luasnip')

local select_opts = {behavior = cmp.SelectBehavior.Select}

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end
  },
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp', keyword_length = 1},
    {name = 'buffer', keyword_length = 3},
    {name = 'luasnip', keyword_length = 2},
  },
  window = {
    documentation = cmp.config.window.bordered()
  },
  formatting = {
    fields = {'menu', 'abbr', 'kind'},
    format = function(entry, item)
      local menu_icon = {
        nvim_lsp = 'λ',
        luasnip = '⋗',
        buffer = 'Ω',
        path = '🖫',
      }

      item.menu = menu_icon[entry.source.name]
      return item
    end,
  },
  mapping = {
    ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
    ['<Down>'] = cmp.mapping.select_next_item(select_opts),

    ['<C-p>'] = cmp.mapping.select_prev_item(select_opts),
    ['<C-n>'] = cmp.mapping.select_next_item(select_opts),

    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),

    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-y>'] = cmp.mapping.confirm({select = true}),
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    ['<C-f>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, {'i', 's'}),

    ['<C-b>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {'i', 's'}),

    ['<Tab>'] = cmp.mapping(function(fallback)
      local col = vim.fn.col('.') - 1

      if cmp.visible() then
        cmp.select_next_item(select_opts)
      elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        fallback()
      else
        cmp.complete()
      end
    end, {'i', 's'}),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item(select_opts)
      else
        fallback()
      end
    end, {'i', 's'}),
  },
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      -- disable virtual text
      virtual_text = true,

      -- show signs
      signs = true,

      -- delay update diagnostics
      update_in_insert = false,
      -- display_diagnostic_autocmds = { "InsertLeave" },

    }
  )

local colors = {
    purple = "#ffffff",
    gray = "#AAAAAA",
    red = "#FF0000",
}

require'cokeline'.setup({
-- show_if_buffers_are_at_least = 2,
mappings = {
      cycle_prev_next = true,
},
default_hl = {
        fg = function(buffer)
            return buffer.is_focused and colors.purple or colors.gray
        end,
        bg = "NONE",
        style = function(buffer)
            return buffer.is_focused and "bold" or nil
        end,
    },

    components = {
      -- {
      --   text = function(buffer)
      --       return buffer.index ~= 1 and "  "
      --   end,
      -- },
      {
        text = function(buffer)
            return buffer.index .. ": "
        end,
        style = function(buffer)
            return buffer.is_focused and "bold" or nil
        end,
      },
      -- {
      --   text = function(buffer)
      --       return buffer.unique_prefix
      --   end,
      --   fg = function(buffer)
      --       return buffer.is_focused and colors.purple or colors.gray
      --   end,
      --   style = "italic",
      -- },
      {
        text = function(buffer)
            return buffer.filename .. " "
        end,
        style = function(buffer)
            return buffer.is_focused and "bold" or nil
        end,
      },
      {
        text = "  ",
      },
    },
  })
