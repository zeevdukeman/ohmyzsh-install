#!/bin/bash
## Oh My Zsh Installation Script FOR Arch, Debian, and Fedora based systems

## one line install:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/zeevdukeman/ohmyzsh-install/main/install.sh)"

# if $ZSH exist, ask user if they want to unset it first
if [ -n "$ZSH" ]; then
    read -p "ZSH environment variable is set to '$ZSH'. Do you want to unset it? (y/n) " yn
    case $yn in
        [Yy]* ) unset ZSH; echo "ZSH variable unset.";;
        [Nn]* ) echo "Continuing with existing ZSH variable.";;
        * ) echo "Please answer yes or no."; exit 1;;
    esac
fi

PKG_MANAGER=""
THEME=""
PLUGINS=()

set_defaults() {
    THEME="ohmyz"
    PLUGINS=("git" "z" "sudo" "extract" "history" "colored-man-pages" "zsh-autosuggestions" "zsh-syntax-highlighting")
}

# check_which_pkg_manager() {
#     if command -v apt &> /dev/null; then
#         PKG_MANAGER="apt"
#     elif command -v pacman &> /dev/null; then
#         PKG_MANAGER="pacman"
#     elif command -v dnf &> /dev/null; then
#         PKG_MANAGER="dnf"
#     else
#         echo "No supported package manager found (apt, pacman, or dnf). Exiting."
#         exit 1
#     fi
# }
# Configuration
set_defaults
check_which_pkg_manager

set_config() {
    # read -p "Enter package manager (apt/pacman) [default: apt]: " input_pkg_manager
    # PKG_MANAGER=${input_pkg_manager:-$PKG_MANAGER}

    read -p "Enter Oh My Zsh theme [default: $THEME]: " input_theme
    THEME=${input_theme:-$THEME}

    echo "Enter plugins to install (space-separated) [default: ${PLUGINS[*]}]: "
    read -a input_plugins
    if [ ${#input_plugins[@]} -ne 0 ]; then
        PLUGINS=("${input_plugins[@]}")
    fi
}

# install_dependencies() {
#     if [ "$PKG_MANAGER" = "apt" ]; then
#         sudo apt update
#         sudo apt install -y zsh curl git
#     elif [ "$PKG_MANAGER" = "pacman" ]; then
#         sudo pacman -Sy --noconfirm zsh curl git
#     elif [ "$PKG_MANAGER" = "dnf" ]; then
#         sudo dnf install -y zsh curl git
#     fi
# }

#
check_dependencies() {
    dependencies=(zsh curl git)
    missing_deps=()
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "The following dependencies are missing: ${missing_deps[*]}"
        exit 1
    fi
}

install_ohmyzsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

change_default_shell() {
    if ! command -v zsh &> /dev/null; then
        echo "zsh could not be found, cannot change default shell."
        return
    fi

    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s "$(which zsh)"
    fi
}


# function to check if .zshrc contains those settings already and if not, add them

contain() {
  local setting="$1"
  local value="$2"
  local target="$3"
  local should_export=${4:-true}
  if ! grep -q "^$setting=" "$target"; then
    if [ "$should_export" = true ]; then
      echo "export $setting=\"$value\"" >> "$target"
    else
      echo "$setting=\"$value\"" >> "$target"
    fi
  fi
}


configure_ohmyzsh() {
  ZSHRC="$HOME/.zshrc"
  ZSH="$HOME/.oh-my-zsh"
  ZSH_THEME="ohmyz"
  EDITOR=fresh
  
  plugins=(git z sudo extract history colored-man-pages zsh-autosuggestions zsh-syntax-highlighting)

  source $ZSH/oh-my-zsh.sh
  
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  contain "ZSH" "$ZSH" "$ZSHRC"
  contain "ZSH_THEME" "$ZSH_THEME" "$ZSHRC"
  contain "EDITOR" "$EDITOR" "$ZSHRC"
  # Set theme
  # sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"$THEME\"/" "$HOME/.zshrc"






  # Add plugins
  local plugins_line="plugins=(${PLUGINS[*]})"
  sed -i "s/^plugins=.*/$plugins_line/" "$HOME/.zshrc"

  # Install additional plugins
  if [[ " ${PLUGINS[@]} " =~ " zsh-autosuggestions " ]]; then
    if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
      git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
    fi
  fi
  if [[ " ${PLUGINS[@]} " =~ " zsh-syntax-highlighting " ]]; then
    if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
      git clone https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
    fi
  fi
}
post_installation() {
  cp ./ohmyz.zsh-theme ~/.oh-my-zsh/themes/ohmyz.zsh-theme
  configure_ohmyzsh
  
  echo "Oh My Zsh has been configured with theme '$THEME' and plugins: ${PLUGINS[*]}"

  echo "To apply changes, please restart your terminal or run 'source ~/.zshrc'."
}

run_installation() {
  echo "Starting installation..."
  check_dependencies
  change_default_shell
  install_ohmyzsh
  post_installation
  echo "Installation complete! Please restart your terminal."
  # press any key to exit
  read -n 1 -s -r -p "Press any key to exit..."
  exit 0
}

set_config
run_installation
