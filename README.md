# Liam's simple bash scripts

These are basic quality of life bash scripts for things I do regularly.

To install most dependencies on Arch run:

    sudo pacman -S --needed pacman-contrib fwupdmgr rclone pandoc neovim reflector fzf

yay must be manually installed if you haven't already installed it. `gnome-pomodoro` can be installed with the PKGBUILD from the AUR (where I'm the current maintainer of the PKGBUILD).

Before running any script with rclone, you need to set it up manually.

## archinfo
Provides search interface to get detailed info about any *installed* package.
* usage: run `archinfo` then start typing the name of a program installed on your system, hit <enter> to print info on one, use <tab> to select multiple
* dependencies: `fzf`, `pacman`

## archremove
Uninstalled Arch prackages with my preferred options.
* usage: `archremove <program>`
* dependencies: `pacman`

## archsearch
Provides search interface to find and install packages from the official Arch repos.
* usage: run `archsearch` then start typing the name of a program in the official repos, hit enter on the one you want and you will be prompted to enter your password to install it.
* dependencies: `fzf`, `pacman`

## archtest
Unfinished. Aimed at testing AUR packages.

## archupdate
First checks if there is a battery (laptop), **refuses to update if not on AC power**! Then, checkes time since last mirrorlist change, then updates Arch Linux including AUR builds via `yay`, and cleans up the pacman cache. If **the mirror list hasn't been updated in a week it:** ranks mirrors, updates the mirror list, updates firmware if applicable, updates this collection of bashscripts and updates neovim plugins
* usage: just run `archupdate` when you like
* dependencies: `pacman` (always there on Arch), `reflector`, `fwupdmgr`, `yay`, `pacman-contrib`, `neovim` with vim-plug (see my dotfiles)

Note: much of this could be accomplished with pacman hooks but not all of this concerns `pacman` and other updaters could be added in the future. Power check is there because I've had major system corruption more than once due to a failing battery cutting power in the middle of firmware and/or kernel updates. Fixing these can be a huge pain, that part can be deleted if it's not applicable to your setup.

## backup
just an `rsync` wrapper for making a backup from one of my machines

## chill
uses `youtube-dl` with `mpv` to stream *lofi hip hop radio - beats to relax/study to* from youtube.
usage: `chill`
dependencies: `youtube-dl`, `mpv`, internet connection

## gdrive
Implementing `git` like syntax for interacting with google drive. I am not currently using this since newer versions of Nautilus have usable google drive support built in.
* usage: implements easier syntax for rclone, including cloning from google drive, pulling updates from google drive, and pushing new files to google drive
* dependencies: `rclone` configured for google drive

## goodmorning
Greets the user in the morning, displays weather for 5 minutes (get coffee!), then starts `gnome-shell-pomodoro` and opens a file called `~/Documents/notes/todo.md` using the `notes` script here.
* usage: `goodmorning`,
* dependencies: the `notes` script, `gnome-pomodoro`, `espeak`

## goodnight
Place-holder. I've got ideas but too inconsistent in the evening.

## gourcegif
Creates a gif from git history.
* dependencies: `gource`

## idk
Gathers a few sources for quick info on commands and programs.
* usage: `idk <program>` then hit `y` to step through more information.

## imageextract
Pulls all images out of a set of pdfs in a directory.

## journal
Place-holder for if I decide to start journaling.

## module-update
Backend for a way-bar status indicator in swaywm.
* usage: see my way-bar configs

## newscript
Takes a filename, makes a new bash script file with that name and makes it executable
* usage: `newscript <NameOfaScriptYouWantToMake>`

## notes
Takes a file name, makes a new markdown file with formatted header in a ~Documents/notes/ directory and opens the file in neovim
* usage: `notes <NameOfaNewNote>` or just use `notes` to select from a list of existing notes
* dependencies: `fzf`, enviromnental variable `$EDITOR` should be set.

note: you'll want to edit the header it puts in new notes since that has my name in it

## pdfpreview
Converts Markdown to pdf on each save to preview a document.
* usage: `pdfpreview <markdownFile.md>`
* dependencies: `pandoc`, `entr`, `zathura`

## presentation
Takes markdown file and converts it to a pdf document (`filename_notes.pdf`) and a pdf slide show (`filename_slides.pdf`). Note that the markdown is carefully broken up by headers and subheaders there is a high likelyhood of text and images overflowing on the slides.
* usage:
* dependencies: `pandoc`

## screenshots

## word2md
Converts a Microsoft Word document to Markdown, puts the figures in a folder. Just wraps pandoc with some nice options.
* usage: `word2md <markdownFile.md>`
* dependencies: `pandoc`
