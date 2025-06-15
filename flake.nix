{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
		mac-app-util.url = "github:hraban/mac-app-util";
		home-manager.url = "github:nix-community/home-manager";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, mac-app-util, home-manager }:
  let
    system = "aarch64-darwin";
    username = "kociola";
    homeDir = "/Users/${username}";

    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
      [ 
				pkgs.vim
				pkgs.kitty # terminal emulator
      ];

			# User config.
			users.users.${username} = {
				home = homeDir;
        shell = pkgs.zsh;
			};

			# Required for i.e. homebrew
			system.primaryUser = username;

			# Homebrew
			homebrew = {
				enable = true;
				casks = [
					"logi-options+" # keyboard & mouse drivers
				];
				onActivation.cleanup = "zap";
				onActivation.autoUpdate = true;
				onActivation.upgrade = true;
			};

      # Fonts
      fonts.packages = [
				pkgs.nerd-fonts.jetbrains-mono
      ];

      # Zsh setup.
      programs.zsh.enable = true;

      # Necessary for Determinate nix.
      nix.enable = false;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

			# System settings.
			system.defaults = {
				# NSGlobalDomain.
				NSGlobalDomain.AppleICUForce24HourTime = true;
				NSGlobalDomain.AppleInterfaceStyle = "Dark";

				# Finder.
				finder.FXPreferredViewStyle = "clmv";

				# Login window.
				loginwindow.GuestEnabled = false;

				# Control Centre / Menu Bar
				controlcenter.AirDrop = false;
				controlcenter.BatteryShowPercentage = false;
				controlcenter.Bluetooth = false;

				# Dock
				dock.autohide = false;
				dock.magnification = true;
				dock.largesize = 64; # Magnified icon size on hover.
				dock.expose-group-apps = true; # Group windows by application in Mission Control.
				dock.launchanim = true; # Animate opening applications.
				dock.persistent-apps = [ # Apps on dock.
					{ app = "/Applications/Safari.app"; }
					{ app = "/System/Applications/Messages.app"; }
					{ app = "/System/Applications/Mail.app"; }
					{ app = "/System/Applications/Photos.app"; }
					{ app = "/System/Applications/Calendar.app"; }
					{ app = "/System/Applications/Reminders.app"; }
					{ app = "/System/Applications/Notes.app"; }
					{ app = "/System/Applications/Music.app"; }
				];
				dock.show-process-indicators = true; # Indicator if an app is open.
				dock.show-recents = false; # Hide recents.

				# Software Update.
				SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
			};

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = system;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#macbook
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      modules = [ 
				configuration 
				nix-homebrew.darwinModules.nix-homebrew
				{
					nix-homebrew = {
						enable = true;
						# Apple silicon only
						enableRosetta = false;
						# User owning the Homebrew prefix
						user = username;

						autoMigrate = true;
					};
				}
				mac-app-util.darwinModules.default
				home-manager.darwinModules.home-manager
				{
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;
          home-manager.backupFileExtension = ".before-nix-darwin";

					home-manager.users.${username} = { pkgs, ... }: {
						home.homeDirectory = homeDir;
						home.stateVersion = "23.11";

            # Zsh setup.
            programs.zsh = {
              enable = true;
              enableCompletion = true;
              syntaxHighlighting.enable = true;

              initContent = ''
                # Set up Oh My Posh prompt
                eval "$(oh-my-posh init zsh --config https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/catppuccin.omp.json)"

                # Optional aliases
                export EDITOR=nvim
              '';
            };
						
						# Neovim setup.
						programs.neovim = {
							enable = true;
							viAlias = true;
							vimAlias = true;
							withPython3 = true;
							withNodeJs = true;
							withRuby = true;
						};
						
						# Neovim configuration.
						home.file.".config/nvim".source = ./nvim;

            # Kitty terminal configuration.
            home.file.".config/kitty/kitty.conf".source = ./kitty/kitty.conf;

						# Additional tools.
						home.packages = with pkgs; [
              # Neovim
							ripgrep
							fd
							tree-sitter
							lua-language-server
							nodejs
							stylua
              # oh-my-posh
              oh-my-posh
						];
					};
				}
      ];
    };
  };
}
