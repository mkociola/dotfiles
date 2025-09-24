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
          enable = true,
        },
        indent = {
          enable = true,
        },
      },
    },

    -- Telescope
    {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.8",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {
        pickers = {
          find_files = {
            theme = "dropdown",
          },
        },
        extensions = {
          file_browser = {
            theme = "dropdown",
            hijack_netrw = true,
            layout_strategy = "horizontal",
            layout_config = {
              width = 0.9,
              height = 0.5,
              prompt_position = "top",
            },
          },
        },
      },
    },

    -- Telescope file browser
    {
      "nvim-telescope/telescope-file-browser.nvim",
      dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",
      },
    },

    -- Mason (install LSP servers)
    {
      "mason-org/mason.nvim",
      config = function()
        require("mason").setup()
      end,
    },

    -- Nvim lspconfig (premade LSP configurations)
    { "neovim/nvim-lspconfig" },

    -- Mason lspconfig (bridge between mason and lspconfig)
    {
      "mason-org/mason-lspconfig.nvim",
      dependencies = { "mason.nvim", "nvim-lspconfig" },
      config = function()
        require("mason-lspconfig").setup({
          ensure_installed = {
            -- LSPs
            "lua_ls",
            "pyright",

            -- Formatters
            "stylua",
          },
        })
      end,
    },

    -- Autoparis
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = true,
    },

    -- Gitsigns
    {
      "lewis6991/gitsigns.nvim",
    },

    -- Mini
    -- Surround
    {
      "echasnovski/mini.surround",
      version = false,
      opts = {},
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
      end,
    },
  },

  -- Automatically check for plugin updates
  checker = { enabled = false },
})

-- Load Telescope extensions
require("telescope").load_extension("file_browser")

--
-- Keymaps
--
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>") -- Clear highlights on Esc

-- Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>e", ":Telescope file_browser path=%:p:h select_buffer=true<CR>")

-- LSP
vim.diagnostic.config({
  virtual_text = true,
  underline = true,
  severity_sort = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("my.lsp", {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    -- Auto format
    if
        not client:supports_method("textDocument/willSaveWaitUntil")
        and client:supports_method("textDocument/formatting")
    then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("my.lsp", { clear = false }),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
        end,
      })
    end
  end,
})
