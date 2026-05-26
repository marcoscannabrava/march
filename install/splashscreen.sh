#!/bin/bash
sudo mv /usr/share/plymouth/themes/omarchy/logo.png /usr/share/plymouth/themes/omarchy/logo.png.bkp
sudo cp logo.png /usr/share/plymouth/themes/omarchy

# same for /home/marcos/.local/share/omarchy/default/plymouth/logo.png
sudo mv /home/marcos/.local/share/omarchy/default/plymouth/logo.png /home/marcos/.local/share/omarchy/default/plymouth/logo.png.bkp
sudo cp logo.png /home/marcos/.local/share/omarchy/default/plymouth