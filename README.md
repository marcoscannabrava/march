# dotfiles for a very nice (m)arch

> thanks Omarchy for all the quality of life improvements

```sh
# this install omarchy base
./install.sh -o

# this install customizations
./install.sh -pswk

```

# cool stuff

## timer
```sh
# run to start a timer that shows up on waybar!
timer 5m
timer 30s
```

# known issues
## elephant-windows
Because Omarchy repo has its own version of the elephant package. Upgrading system packages **might** pull a newer version of elephant plugins from AUR. This version mismatch **might** break if the Go used to compile the plugin is different from the one used to compile the main package. The solution is to manually build the plugin with the system's Go.