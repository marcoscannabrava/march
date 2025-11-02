echo "source ~/.config/zsh/.zshrc" > ~/.zshrc
echo "source ~/.config/zsh/.aliases" >> ~/.zshrc

# change user default shell
sudo chsh -s `which zsh`

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install plugins:
# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# reload shell
source ~/.zshrc