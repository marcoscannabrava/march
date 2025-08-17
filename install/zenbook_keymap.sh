# zenbook has a dumb copilot key, make it useful
sudo ln -s "$PWD/keyd.zenbook.conf" "/etc/keyd/default.conf"
sudo keyd reload