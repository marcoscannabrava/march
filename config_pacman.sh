if [ ! -f /etc/pacman.conf.bkp ]; then
    sudo cp /etc/pacman.conf /etc/pacman.conf.bkp
    sudo sed -i "/^#Color/c\Color\nILoveCandy
    /^#VerbosePkgLists/c\VerbosePkgLists
    /^#ParallelDownloads/c\ParallelDownloads = 5" /etc/pacman.conf
    sudo sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf
    exit 0
fi
exit 1