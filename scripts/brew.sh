if [[ -z "$(command -v brew)" ]]; then
  # Install Homebrew.
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  brew update
  brew install ripgrep fd exa bat git-delta neovim 
fi
