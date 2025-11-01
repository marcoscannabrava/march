# zenbook has a dumb copilot key, make it useful
yay -S keyd
sudo systemctl enable --now keyd
sudo ln -s "$PWD/install/zenbook.keyd.conf" "/etc/keyd/default.conf"
sudo keyd reload