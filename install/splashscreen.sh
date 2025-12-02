#!/bin/bash
mv /usr/share/plymouth/themes/omarchy/logo.png /usr/share/plymouth/themes/omarchy/logo.png.bkp
cp logo.png /usr/share/plymouth/themes/omarchy
sudo limine-update