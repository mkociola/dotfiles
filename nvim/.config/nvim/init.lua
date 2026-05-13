-- Disable netrw (telescope-file-browser is the file explorer)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 10
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true
vim.opt.completeopt = "menu,menuone,noselect"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- Treesitter
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			main = "nvim-treesitter.configs",
			opts = {
				auto_install = true,
				highlight = { enable = true },
				indent = { enable = true },
			},
		},

		-- Telescope
		{
			"nvim-telescope/telescope.nvim",
			tag = "0.1.8",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-telescope/telescope-file-browser.nvim",
				"nvim-telescope/telescope-ui-select.nvim",
			},
			opts = {
				extensions = {
					file_browser = {
						hijack_netrw = false,
						sorting_strategy = "ascending",
					},
				},
			},
			config = function(_, opts)
				require("telescope").setup(opts)
				require("telescope").load_extension("file_browser")
				require("telescope").load_extension("ui-select")

				local builtin = require("telescope.builtin")
				vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
				vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
				vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
				vim.keymap.set(
					"n",
					"<leader>e",
					":Telescope file_browser path=%:p:h select_buffer=true<CR>",
					{ desc = "File browser" }
				)
			end,
		},

		-- LSP
		{ "mason-org/mason.nvim", opts = {} },
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			dependencies = { "mason-org/mason.nvim" },
			opts = {
				ensure_installed = { "lua-language-server", "stylua" },
			},
		},
		{ "neovim/nvim-lspconfig" },

		-- Formatting
		{
			"stevearc/conform.nvim",
			opts = {
				formatters_by_ft = {
					lua = { "stylua" },
				},
				format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
			},
		},

		-- Autopairs
		{ "windwp/nvim-autopairs", event = "InsertEnter", config = true },

		-- Gitsigns
		{
			"lewis6991/gitsigns.nvim",
			opts = {
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns
					vim.keymap.set("n", "]h", gs.next_hunk, { buffer = bufnr })
					vim.keymap.set("n", "[h", gs.prev_hunk, { buffer = bufnr })
				end,
			},
		},

		-- Mini.surround
		{ "echasnovski/mini.surround", version = false, opts = {} },

		-- Completion
		{
			"saghen/blink.cmp",
			version = "1.*",
			dependencies = {
				"rafamadriz/friendly-snippets",
				"fang2hou/blink-copilot",
			},
			opts = {
				keymap = { preset = "default" },
				appearance = { nerd_font_variant = "mono" },
				completion = {
					documentation = { auto_show = true },
					menu = {
						draw = {
							columns = {
								{ "label", "label_description", gap = 1 },
								{ "kind_icon", "kind", gap = 1 },
							},
						},
					},
				},
				sources = {
					default = { "copilot", "lsp", "path", "snippets", "buffer" },
					providers = {
						copilot = {
							name = "copilot",
							module = "blink-copilot",
							score_offset = 100,
							async = true,
						},
					},
				},
				fuzzy = { implementation = "prefer_rust_with_warning" },
			},
		},

		-- Which-key
		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			opts = { preset = "modern" },
		},

		-- toggleterm.nvim
		{
			"akinsho/toggleterm.nvim",
			version = "*",
			opts = {
				size = 20,
				open_mapping = [[<c-\>]],
				direction = "float",
				float_opts = { border = "curved" },
			},
		},

		-- Status line
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			opts = {
				options = {
					globalstatus = true, -- Single statusline for all windows (Neovim 0.7+)
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = {
						"encoding",
						"fileformat",
						"filetype",
					},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			},
		},

		-- Icons
		{ "nvim-tree/nvim-web-devicons", opts = {} },

		-- Theme
		{
			"folke/tokyonight.nvim",
			name = "tokyonight",
			priority = 1000,
			config = function()
				vim.cmd.colorscheme("tokyonight-night")
			end,
		},

		-- Copilot
		{
			"zbirenbaum/copilot.lua",
			cmd = "Copilot",
			event = "InsertEnter",
			config = function()
				require("copilot").setup({
					suggestion = { enabled = false },
					panel = { enabled = false },
				})
			end,
		},
	},
	checker = { enabled = false },
})

-- LSP setup
local capabilities = require("blink.cmp").get_lsp_capabilities()
vim.lsp.config["*"] = vim.tbl_deep_extend("force", vim.lsp.config["*"] or {}, {
	capabilities = capabilities,
})

vim.lsp.enable({ "lua_ls" })

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf

		-- Basic keymaps
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
		vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr })
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr })

		-- Inlay hints
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end,
})

-- Diagnostics
vim.diagnostic.config({ virtual_text = true })

-- Keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
