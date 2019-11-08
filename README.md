# Liam's simple bash scripts

These are basic quality of life bash scripts for things I do regularly.

## archupdate
* usage: updates Arch Linux via yay, updates vim-plug and any plugins, cleans up pacman cache, if it hasn't been run in a week it first updates the mirror list and also updates firmware if applicable
* dependencies: only for Arch Linux, reflector, fwupdmgr, yay, pacman-contrib, neovim with vim-plug (see my dotfiles)
much of this could be accomplished with pacman hooks but not all of this concerns pacman and other updaters could be added in the future.

## gdrive
* usage: implements git-like syntax for rclone, including cloning from google drive, pulling updates from google drive, and pushing new files to google drive
* dependencies: rclone configured for google drive

## notes
* usage: takes a file name, makes a new markdown file with formatted header in a ~Documents/notes/ directory and opens the file in neovim
* dependencies: neovim but you can change the editor or just remove the last line if you don't want to use it.

## newscript
* usage: takes a file name, makes it executable
* dependencies: none (unless you count bash)

## presentation
* usage: takes markdown file and converts it to a pdf document (`filename_notes.pdf`) and a pdf slide show (`filename_slides.pdf`). Note that the markdown is carefully broken up by headers and subheaders there is a high likelyhood of text and images overflowing on the slides.
* dependencies: pandoc

to install most dependencies on Arch run:
    sudo pacman -S --needed pacman-contrib fwupdmgr rclone pandoc neovim reflector
yay must be manually installed if you haven't already installed it

before running rclone requires manual intervention if not already set up.
