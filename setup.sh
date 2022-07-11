# starthip
curl -sS https://starship.rs/install.sh | sh -s -- --yes

# tmux and https://github.com/gpakosz/.tmux
sudo apt install tmux -y
git clone --depth=1 https://github.com/gpakosz/.tmux.git ~/.tmux
ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf

# https://github.com/amix/vimrc.git
git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

# pnpm https://pnpm.io/installation
curl -fsSL https://get.pnpm.io/install.sh | sh -

# copy dotfiles
cp -r .config ~/.config
cp .zshrc ~/.zshrc
cp .vim_runtime/my_configs.vim ~/.vim_runtime/my_configs.vim
cp .tmux.conf.local ~/.tmux.conf.local
