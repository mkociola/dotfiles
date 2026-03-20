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
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = {
				extensions = {
					file_browser = {
						hijack_netrw = true,
						sorting_strategy = "ascending",
					},
				},
			},
		},
		{ "nvim-telescope/telescope-file-browser.nvim", dependencies = { "nvim-telescope/telescope.nvim" } },
		-- Mason (note: use :MasonInstall for formatters like stylua/black)
		{ "williamboman/mason.nvim", config = true },
		{ "neovim/nvim-lspconfig" },
		-- Mason-lspconfig (updated for cmp capabilities)
		{
			"williamboman/mason-lspconfig.nvim",
			dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig", "hrsh7th/cmp-nvim-lsp" },
			opts = {
				ensure_installed = { "lua_ls", "pyright" },
				handlers = {
					function(server_name)
						-- Add cmp capabilities for better completion integration
						local capabilities = require("cmp_nvim_lsp").default_capabilities()
						require("lspconfig")[server_name].setup({
							capabilities = capabilities,
							on_attach = function(client, bufnr)
								-- Standard LSP keymaps
								local opts = { buffer = bufnr }
								vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
								vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
								vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
								vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
								vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

								-- Inlay hints
								if client.supports_method("textDocument/inlayHint") then
									vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
								end

								-- Range Formatting Support
								if client.supports_method("textDocument/rangeFormatting") then
									vim.keymap.set("v", "<leader>cf", vim.lsp.buf.format, opts)
								end

								-- On-Type Formatting Support
								if client.supports_method("textDocument/onTypeFormatting") then
									vim.lsp.on_type_formatting.enable(true, { client_id = client.id })
								end
							end,
						})
					end,
				},
			},
		},
		-- conform.nvim for unified formatting
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
						["<C-b>"] = cmp.mapping.scroll_docs(-4),
						["<C-f>"] = cmp.mapping.scroll_docs(4),
						["<C-Space>"] = cmp.mapping.complete(),
						["<C-e>"] = cmp.mapping.abort(),
						["<CR>"] = cmp.mapping.confirm({ select = true }),
					}),
					sources = cmp.config.sources({
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
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			},
		},
		-- Icons and Theme
		{ "nvim-tree/nvim-web-devicons", opts = {} },
		-- Theme
		{
			"rebelot/kanagawa.nvim",
			name = "kanagawa",
			priority = 1000,
			config = function()
				vim.cmd.colorscheme("kanagawa")
			end,
		},
	},
	checker = { enabled = false },
})

-- Load Telescope extensions
require("telescope").load_extension("file_browser")

-- Keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>e", ":Telescope file_browser path=%:p:h select_buffer=true<CR>")

-- Diagnostics config
vim.diagnostic.config({ virtual_text = true })
