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
						hijack_netrw = true,
						sorting_strategy = "ascending",
					},
				},
			},
			config = function()
				-- Load extensions
				require("telescope").load_extension("file_browser")
				require("telescope").load_extension("ui-select")

				-- Keymaps
				local builtin = require("telescope.builtin")
				vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
				vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
				vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
				vim.keymap.set("n", "<leader>e", ":Telescope file_browser path=%:p:h select_buffer=true<CR>")
			end,
		},

		-- LSP
		{ "mason-org/mason.nvim", config = true },
		{
			"mason-org/mason-lspconfig.nvim",
			dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
			opts = {
				ensure_installed = { "lua_ls" },
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

		-- nvim-cmp
		{
			"hrsh7th/nvim-cmp",
			dependencies = {
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-path",
				"L3MON4D3/LuaSnip",
				"saadparwaiz1/cmp_luasnip",
				"onsails/lspkind.nvim",
			},
			config = function()
				local cmp = require("cmp")
				cmp.setup({
					snippet = {
						expand = function(args)
							require("luasnip").lsp_expand(args.body)
						end,
					},
					mapping = cmp.mapping.preset.insert({
						["<CR>"] = cmp.mapping.confirm(),
					}),
					formatting = {
						format = require("lspkind").cmp_format({
							mode = "symbol_text", -- show icon + text
							maxwidth = 50,
							ellipsis_char = "...",
							menu = {
								nvim_lsp = "[LSP]",
								luasnip = "[Snippet]",
								buffer = "[Buffer]",
								path = "[Path]",
							},
						}),
					},
					sources = cmp.config.sources({
						{ name = "copilot" },
						{ name = "nvim_lsp" },
						{ name = "luasnip" },
					}, {
						{ name = "buffer" },
						{ name = "path" },
					}),
				})
			end,
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

		-- AI stuff
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
		{
			"zbirenbaum/copilot-cmp",
			dependencies = { "zbirenbaum/copilot.lua" },
			config = function()
				require("copilot_cmp").setup()
			end,
		},
		{
			"yetone/avante.nvim",
			event = "VeryLazy",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"MunifTanjim/nui.nvim",
				"nvim-tree/nvim-web-devicons",
				"MeanderingProgrammer/render-markdown.nvim",
			},
			build = "make",
			config = function(_, opts)
				require("avante_lib").load()

				require("render-markdown").setup({
					file_types = { "markdown", "Avante" },
				})

				require("avante").setup({
					provider = "copilot",
				})

				vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>AvanteAsk<CR>", { desc = "Avante: Toggle Chat" })
				vim.keymap.set({ "n", "v" }, "<leader>ae", "<cmd>AvanteEdit<CR>", { desc = "Avante: Edit selection" })
				vim.keymap.set({ "n", "v" }, "<leader>ar", "<cmd>AvanteRefresh<CR>", { desc = "Avante: Refresh" })
				vim.keymap.set({ "n", "v" }, "<leader>af", "<cmd>AvanteFocus<CR>", { desc = "Avante: Focus chat" })
			end,
		},
	},
	checker = { enabled = false },
})

-- LSP setup
local capabilities = require("cmp_nvim_lsp").default_capabilities()
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
