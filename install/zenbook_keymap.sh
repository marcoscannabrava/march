# zenbook has a dumb copilot key, make it useful
sudo ln -s "$PWD/install/zenbook.keyd.conf" "/etc/keyd/default.conf"
sudo keyd reload