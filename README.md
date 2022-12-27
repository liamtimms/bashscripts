# Liam's simple bash scripts

These are basic quality of life bash scripts for things I do regularly.

To install most dependencies on Arch run:

    sudo pacman -S --needed pacman-contrib fwupdmgr rclone pandoc neovim reflector fzf

yay must be manually installed if you haven't already installed it. `gnome-pomodoro` can be installed with the PKGBUILD from the AUR (where I'm the current maintainer of the PKGBUILD).

Before running any script with rclone, you need to set it up manually.

## pac

`pac` is a tiny but powerful wrapper for `fzf` and `pacman` which allows you to interacively search for, select, and manage packages installed on your machine or from the official Arch Linux repositories. It is both simple and extremely powerful by leveraging core utils, fzf features, and pacman's many flags. It enables selection of multiple packages to install or uninstall or print the info of selected installed packages.

### Usage

To use the script, with the flaag for your intent:

```bash
/path/to/pacman-fzf.sh [-h|--help] [-v|--version] [-s|--install] [-r|--uninstall] [-q|--info]
```

The available options are:

    -h or --help: Display usage information and exit.
    -v or --version: Display the script version and exit.
    -s or --install: Search for and select packages from the official Arch Linux repositories using fzf, and then install the selected packages using pacman.
    -r or --uninstall: Select installed packages using fzf, and then uninstall the selected packages using pacman.
    -q or --info: Search for and select an installed package using fzf, and then display information about the selected package using pacman.

Run the script and you will be presented with a search interface powered by fzf. Begin typing the name of the package(s) you want to (un)install, and use the space bar to preview information about packages. To select multiple packages flag them with by hitting Tab. When you have selected the package(s) you want, press Enter to pass the selection to pacman.

### Customization

You can customize the behavior of the fzf search windows by modifying the \_fzf_flags variable at the top of the script. For example, you can change the --ansi flag to --no-ansi to disable ANSI color output, or you can add the --reverse flag to reverse the order of the search results. Consult the fzf documentation for a full list of options.

## archinfo

Provides search interface to get detailed info about any _installed_ package through the Arch Linux package manager `pacman`.

- usage: run `archinfo` then start typing the name of a program installed on your system, hit <enter> to print info on one, use <tab> to select multiple entries.
- dependencies: `fzf`, `pacman`

## archremove

Search uninstall packages through `pacman` with my preferred options.

- usage: `archremove`
- dependencies: `fzf`, `pacman`

## archsearch

Provides search interface to find and install packages from the official Arch repos.

- usage: run `archsearch` then start typing the name of a program in the official repos, hit enter on the one you want and you will be prompted to enter your password to install it.
- dependencies: `fzf`, `pacman`

## archtest

Unfinished. Aimed at testing AUR packages.

## archupdate

First checks if there is a battery (laptop), **refuses to update if not on AC power**! Then, checkes time since last mirrorlist change, then updates Arch Linux including AUR builds via `paru`, and cleans up the pacman cache. If **the mirror list hasn't been updated in a week it:** ranks mirrors, updates the mirror list, updates firmware if applicable, updates this collection of bashscripts and updates neovim plugins

- usage: just run `archupdate` when you like
- dependencies: `pacman` (always there on Arch), `reflector`, `fwupdmgr`, `paru`, `pacman-contrib`, `neovim` with vim-plug (see my dotfiles)

Note: much of this could be accomplished with pacman hooks but not all of this concerns `pacman` and other updaters could be added in the future. Power check is there because I've had major system corruption more than once due to a failing battery cutting power in the middle of firmware and/or kernel updates. Fixing these can be a huge pain, that part can be deleted if it's not applicable to your setup.

## backup

just an `rsync` wrapper for making a backup from one of my machines

## chill

uses `youtube-dl` with `mpv` to stream music from youtube.
Options:
-l = lofi lofi beats
-p = piano relaxing piano
-s = social social network
usage: `chill -l`
dependencies: `youtube-dl`, `mpv`

## gdrive

Implementing `git` like syntax for interacting with google drive. I am not currently using this since newer versions of Nautilus have usable google drive support built in.

- usage: implements easier syntax for rclone, including cloning from google drive, pulling updates from google drive, and pushing new files to google drive
- dependencies: `rclone` configured for google drive

## goodmorning

Greets the user in the morning, displays weather for 5 minutes (get coffee!), then starts `gnome-shell-pomodoro` and opens a file called `~/Documents/notes/todo.md` using the `notes` script here.

- usage: `goodmorning`,
- dependencies: the `notes` script, `gnome-pomodoro`, `espeak`

## goodnight

Place-holder. I've got ideas but too inconsistent in the evening.

## gourcegif

Creates a gif from git history.

- usage: `gourcegif` inside a git repo.
- dependencies: `gource`

## idk

Gathers a few sources for quick info on commands and programs.

- usage: `idk <program>` then hit `y` to step through more information.

## imageextract

Pulls all images out of a set of pdfs in a directory.

- dependencies: `gource` inside a git repo.

## journal

Place-holder for if I decide to start journaling.

## module-update

Backend for a way-bar status indicator in swaywm.

- usage: see my way-bar configs

## newscript

Takes a filename, makes a new bash script file with that name and makes it executable

- usage: `newscript <NameOfaScriptYouWantToMake>`

## notes

Takes a file name, makes a new markdown file with formatted header in a ~Documents/notes/ directory and opens the file in neovim

- usage: `notes <NameOfaNewNote>` or just use `notes` to select from a list of existing notes
- dependencies: `fzf`, enviromnental variable `$EDITOR` should be set.

note: you'll want to edit the header it puts in new notes since that has my name in it

## pdfpreview

Converts Markdown to pdf on each save to preview a document.

- usage: `pdfpreview <markdownFile.md>`
- dependencies: `pandoc`, `entr`, `zathura`

## presentation

Takes markdown file and converts it to a pdf document (`filename_notes.pdf`) and a pdf slide show (`filename_slides.pdf`). Note that the markdown is carefully broken up by headers and subheaders there is a high likelyhood of text and images overflowing on the slides.

- usage:
- dependencies: `pandoc`

## screenshots

## word2md

Converts a Microsoft Word document to Markdown, puts the figures in a folder. Just wraps pandoc with some nice options.

- usage: `word2md <markdownFile.md>`
- dependencies: `pandoc`
