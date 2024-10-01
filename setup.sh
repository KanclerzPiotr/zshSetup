#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y zsh python-is-python3 bat fzf python3-dev python3-pip python3-setuptools zoxide ripgrep fd-find micro

# Install eza
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza

# Change the default shell to Zsh
chsh -s $(which zsh)

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh is already installed."
fi

# Install Oh My Zsh plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions

# Add zsh-completions to fpath
if ! grep -q "fpath+=$ZSH_CUSTOM/plugins/zsh-completions" ~/.zshrc; then
    echo "Adding zsh-completions to fpath in .zshrc"
    echo 'fpath+=$ZSH_CUSTOM/plugins/zsh-completions' >> ~/.zshrc
fi

# Set Zsh theme to jonathan
if ! grep -q "ZSH_THEME=\"jonathan\"" ~/.zshrc; then
    echo "Setting Zsh theme to jonathan"
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="jonathan"/' ~/.zshrc
fi

# Add ZOXIDE_CMD_OVERRIDE variable before plugins
if ! grep -q "ZOXIDE_CMD_OVERRIDE=cd" ~/.zshrc; then
    echo "Adding ZOXIDE_CMD_OVERRIDE=cd to .zshrc"
    echo 'export ZOXIDE_CMD_OVERRIDE=cd' >> ~/.zshrc
fi

# Add zstyle configurations for eza and alias-finder before plugins
if ! grep -q "zstyle ':omz:plugins:eza'" ~/.zshrc; then
    echo "Adding zstyle configurations for eza and alias-finder"
    echo "zstyle ':omz:plugins:eza' 'dirs-first' yes" >> ~/.zshrc
    echo "zstyle ':omz:plugins:eza' 'header' yes" >> ~/.zshrc
    echo "zstyle ':omz:plugins:eza' 'icons' yes" >> ~/.zshrc

    echo "zstyle ':omz:plugins:alias-finder' autoload yes" >> ~/.zshrc
    echo "zstyle ':omz:plugins:alias-finder' longer yes" >> ~/.zshrc
    echo "zstyle ':omz:plugins:alias-finder' exact yes" >> ~/.zshrc
    echo "zstyle ':omz:plugins:alias-finder' cheaper yes" >> ~/.zshrc
fi

# Add plugins to .zshrc if not already present
if ! grep -q "alias-finder" ~/.zshrc; then
    echo "Adding alias-finder, extract, eza, fzf, zoxide, copypath, zsh-syntax-highlighting, zsh-autosuggestions, and zsh-completions to .zshrc"
    sed -i 's/plugins=(git)/plugins=(git alias-finder sudo extract eza fzf zoxide copypath zsh-syntax-highlighting zsh-autosuggestions zsh-completions)/' ~/.zshrc
fi

# Install zoxide initialization in .zshrc
if ! grep -q "eval \$(zoxide init zsh)" ~/.zshrc; then
    echo "Adding zoxide initialization to .zshrc"
    echo "eval \$(zoxide init zsh)" >> ~/.zshrc
fi

# Add fzfp alias to run fzf with bat preview
if ! grep -q "alias fzfp" ~/.zshrc; then
    echo "Adding alias fzfp to .zshrc"
    echo "alias fzfp='fzf --preview \"bat --style=numbers --color=always --line-range=:500 {}\"'" >> ~/.zshrc
fi

# Add FZF default commands and options using fd and preview options at the bottom of the file
if ! grep -q "FZF_DEFAULT_COMMAND" ~/.zshrc; then
    echo "Adding FZF default commands using fd"
    echo 'export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"' >> ~/.zshrc
    echo 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' >> ~/.zshrc
    echo 'export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"' >> ~/.zshrc

    echo "Adding FZF control and alt options"
    echo 'export FZF_CTRL_T_OPTS="--preview '\''bat -n --color=always --line-range :500 {}'\''"' >> ~/.zshrc
    echo 'export FZF_ALT_C_OPTS="--preview '\''eza --tree --color=always {} | head -200'\''"' >> ~/.zshrc

    echo '_fzf_compgen_path() {' >> ~/.zshrc
    echo '  fd --hidden --exclude .git . "$1"' >> ~/.zshrc
    echo '}' >> ~/.zshrc

    echo '_fzf_compgen_dir() {' >> ~/.zshrc
    echo '  fd --type=d --hidden --exclude .git . "$1"' >> ~/.zshrc
    echo '}' >> ~/.zshrc

    echo "Adding advanced FZF customization via _fzf_comprun"
    echo '_fzf_comprun() {' >> ~/.zshrc
    echo '  local command=$1' >> ~/.zshrc
    echo '  shift' >> ~/.zshrc
    echo '  case "$command" in' >> ~/.zshrc
    echo '    cd)           fzf --preview '\''eza --tree --color=always {} | head -200'\'' "$@" ;;' >> ~/.zshrc
    echo '    export|unset) fzf --preview "eval '\''echo $'\''{}"         "$@" ;;' >> ~/.zshrc
    echo '    ssh)          fzf --preview '\''dig {}'\''                   "$@" ;;' >> ~/.zshrc
    echo '    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;' >> ~/.zshrc
    echo '  esac' >> ~/.zshrc
    echo '}' >> ~/.zshrc
fi


echo "Setup complete! Please restart your terminal or log out and log back in to use Zsh."
