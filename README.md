# nix-config — macOS Setup with Nix, nix-darwin, and Home Manager

This repository contains my declarative macOS system configuration using:

- 🧰 [Nix](https://nixos.org)
- 🍎 [nix-darwin](https://github.com/LnL7/nix-darwin)
- 🏡 [Home Manager](https://github.com/nix-community/home-manager)
- 🔧 [Flakes](https://nixos.wiki/wiki/Flakes)
- 🚀 [Determinate Systems Nix Installer](https://github.com/determinateSystems/nix-installer)

---

## ✅ Features

- System-wide macOS settings (dark mode, dock, Finder, etc.)
- Shell setup with `zsh` and [Oh My Posh](https://ohmyposh.dev)
- Neovim with custom config
- Kitty terminal config
- Fonts, CLI tools, and GUI apps via `nix-homebrew`
- Everything managed declaratively and reproducibly

---

## 🧱 Requirements

- macOS (tested on Ventura and Sonoma)
- Admin privileges
- Xcode Command Line Tools installed:
  ```bash
  xcode-select --install
  ```

---

## 🚀 First-Time Setup (Fresh MacBook)

```bash
# 1. Install Nix using Determinate Systems (safe, fast)
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate

# 2. Clone this repository
git clone https://github.com/mkociola/dotfiles.git ~/nix-config
cd ~/nix-config

# 3. Apply the configuration
sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake .#macbook
```

✅ Done! Your system is now bootstrapped with your full setup.

---

## 🔁 Reapply config after changes

```bash
cd ~/nix-config
darwin-rebuild switch --flake .#macbook
```

---

## 📜 License

MIT — do whatever you want.
