# Liam's simple bash scripts

These are basic quality of life bash scripts for things I do regularly.

To install most dependencies on Arch run:

    sudo pacman -S --needed pacman-contrib fwupdmgr rclone pandoc neovim reflector fzf

yay must be manually installed if you haven't already installed it

Before running any script with rclone, you need to set it up manually.

## archinfo
* usage: Provides search interface to get detailed info about any *installed* package.
* dependencies: `fzf`

## archremove
* usage: uninstalled Arch prackages with my preferred options.

## archsearch
Provides search interface to find and install packages from the official Arch repos.
* usage: run `archsearch` then start typing the name of a program, hit enter on the one you want and you will be prompted to enter your password to install it.
* dependencies: `fzf`

## archtest
Unfinished. Aimed at testing AUR packages.

## archupdate
* usage: updates Arch Linux via yay, updates vim-plug and any plugins, cleans up pacman cache, if it hasn't been run in a week it first updates the mirror list and also updates firmware if applicable
* dependencies: only for Arch Linux, reflector, fwupdmgr, yay, pacman-contrib, neovim with vim-plug (see my dotfiles)

Note that much of this could be accomplished with pacman hooks but not all of this concerns `pacman` and other updaters could be added in the future.

## backup
just an `rsync` wrapper for making a backup from one of my machines

## chill
uses `youtube-dl` with `mpv` to stream *lofi hip hop radio - beats to relax/study to* from youtube.

## gdrive
Implementing `git` like syntax for interacting with google drive. I am not currently using this and it may be buggy.
* usage: implements easier syntax for rclone, including cloning from google drive, pulling updates from google drive, and pushing new files to google drive
* dependencies: `rclone` configured for google drive

## goodmorning
Greets the user in the morning, displays weather for 5 minutes, then starts `gnome-shell-pomodoro` and opens a file called `~/Documents/notes/todo.md` similar to the `notes` script here.

## goodnight
Place-holder.

## gourcegif
Creates a gif from git history.
* dependencies: `gource`

## idk
Gathers a few sources for quick info on commands and programs.
* usage: give it a file name or command, eg. `idk xargs`, press `y` to continue getting info.

## imageextract
Pulls all images out of a set of pdfs in a directory.

## journal
## module-update
## newscript
* usage: takes a filename, makes a new bash script file with that name and makes it executable
* dependencies: none (unless you count bash)

## notes
* usage: takes a file name, makes a new markdown file with formatted header in a ~Documents/notes/ directory and opens the file in neovim
* dependencies: `neovim` but you can change the editor or just remove the last line if you don't want to use it.

## pdfpreview
Converts Markdown to pdf on each save to preview a document.

## presentation
* usage: takes markdown file and converts it to a pdf document (`filename_notes.pdf`) and a pdf slide show (`filename_slides.pdf`). Note that the markdown is carefully broken up by headers and subheaders there is a high likelyhood of text and images overflowing on the slides.
* dependencies: `pandoc`

## screenshots

## word2md
Converts a Microsoft Word document to Markdown.
