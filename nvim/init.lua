--
-- Bootstrap lazy.nvim
--
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

--
-- Settings
--
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- General
vim.opt.cursorline = true

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 10

-- Use spaces for tabs and whatnot
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

--
-- Setup lazy.nvim
--
require("lazy").setup({
  spec = {

    -- Treesitter
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      main = "nvim-treesitter.configs",
      opts = {
        auto_install = true,
        highlight = {
          enable = true
        },
        indent = {
          enable = true
        }
      }
    },

    -- Telescope
    {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.8",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {
        pickers = {
          find_files = {
            theme = "dropdown"
          }
        },
        extensions = {
          file_browser = {
            theme = "dropdown",
            hijack_netrw = true,
            layout_strategy = "horizontal",
            layout_config = {
              width = 0.9,
              height = 0.5,
              prompt_position = "top"
            }
          }
        }
      }
    },

    -- Telescope file browser
    {
      "nvim-telescope/telescope-file-browser.nvim",
      dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim"
      },
    },

    -- Auto LSP setup
    {
      "dundalek/lazy-lsp.nvim",
      dependencies = {
        "neovim/nvim-lspconfig",
        { "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/nvim-cmp",
      },
      config = function()
        local lsp_zero = require("lsp-zero")

        lsp_zero.on_attach(function(client, bufnr)
          -- see :help lsp-zero-keybindings to learn the available actions
          lsp_zero.default_keymaps({
            buffer = bufnr,
            preserve_mappings = false
          })
        end)

        require("lazy-lsp").setup {}
      end,
    },

    -- Auto formatting
    {
      "stevearc/conform.nvim",
      opts = {
        format_on_save = {
          timeout_ms = 500,
          lsp_format = "fallback"
        }
      }
    },

    -- Autoparis
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = true
    },

    -- Mini
    -- Surround
    {
      "echasnovski/mini.surround",
      version = false,
      opts = {}
    },

    -- Icons
    { "nvim-tree/nvim-web-devicons", opts = {} },

    -- Theme
    {
      "vague2k/vague.nvim",
      name = "vague",
      priority = 1000,
      config = function()
        require("vague").setup({})
        vim.cmd([[colorscheme vague]])
      end
    },

    -- Luasnip
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp"
    }
  },

  -- Automatically check for plugin updates
  checker = { enabled = true }
})

-- Load Telescope extensions
require("telescope").load_extension "file_browser"

--
-- Keymaps
--
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>") -- Clear highlights on Esc

-- Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set("n", "<leader>e", ":Telescope file_browser path=%:p:h select_buffer=true<CR>")
