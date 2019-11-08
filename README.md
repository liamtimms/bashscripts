# Liam's simple bash scripts

These are basic quality of life bash scripts for things I do regularly.

## Archupdate
* usage: updates Arch Linux via yay, updates vim-plug and any plugins, updates firmware if applicable, cleans up pacman cache
* dependencies: only for Arch Linux, fwupdmgr, yay, pacman-contrib, neovim with vim-plug (see my dotfiles)

## gdrive
* usuage: implements git-like syntax for rclone, including cloning from google drive, pulling updates from google drive, and pushing new files to google drive

## Dependencies
* gdrive: rclone configured for google drive
* presentation: pandoc
* notes: none
* newscript: neovim

to install most dependencies on Arch:
    sudo pacman -S pacman-contrib fwupdmgr rclone pandoc neovim

yay and vim-plug require manual itervention.
