# starthip
curl -sS https://starship.rs/install.sh | sh -s -- --yes

# tmux and https://github.com/gpakosz/.tmux
sudo apt install tmux -y
git clone --depth=1 https://github.com/gpakosz/.tmux.git ~/.tmux
ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf

# https://github.com/amix/vimrc.git
git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh