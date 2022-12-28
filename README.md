# Liam's simple bash scripts

These are basic quality of life bash scripts for things I do regularly.

To install most dependencies on Arch run:

    sudo pacman -S --needed pacman-contrib fwupdmgr rclone pandoc neovim reflector fzf

Paru must be manually installed if you haven't already installed it. `gnome-pomodoro` can be installed with the PKGBUILD from the AUR (where I'm the current maintainer of the PKGBUILD).

Before running any script with rclone, you need to configure it to use your cloud drive of choice.

## pac

`pac` is a tiny but powerful wrapper for `fzf` and `pacman` which allows you to interacively search for, select, and manage packages installed on your machine or from the official Arch Linux repositories. It is both simple and extremely powerful by leveraging core utils, fzf features, and pacman's many flags. It enables selection of multiple packages to install or uninstall or print the info of selected installed packages.

### Usage

To use the script, with the flaag for your intent:

```bash
pac [-h|--help] [-v|--version] [-s|--install] [-r|--uninstall] [-q|--info]
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

## archupdate

Script designed to updates on my entire Arch linux install and setup. To that end it...

1. refreshes the list of Arch servers so that package updates are delivered from fast, online and up to date servers
2. checks for and prints news from ArchLinux.org (which may affect decision to update further)
3. updates official Arch packages
4. builds and updates AUR packages (using `paru`)
5. pulls changes to my local clone of this `bashscripts` repository
6. updates `rust` modules managed by `rustup` (but not the rust toolchain itself which is managed by `pacman`)
7. checks for firmware updates for any connected hardware, updates firmware with `fwupdmgr` where possible
8. updates neovim plugins, updates CoC neovim packages, updates neovim Treesitter language parsers
9. updates `tmux` plugins
10. updates `systemd-boot` bootloader if applicable
11. updates Anaconda python distribution `base` environment

It can also perform basic cleaning and maintaince:

1. cleans the `pacman` cache keeping the latest 3 downloaded versions of each package
2. cleans the `paru` cache, deleting old source tarballs and built packages after 14 days
3. cleans unused tmux and neovim plugins
4. uses `pacdiff` with neovim to allow comparison between existing configuration files and new configuration files delivered by step 2 (saved with `.pacnew` extension)

Prior to doing any of this, it checks if there is a battery (flags it as laptop), **refuses to update if not on AC power**! This is to avoid power loss during updates which can cause issues depnding on which portion of the processes is interrupted.

### Usage

To use the script, simply run it with the appropriate option:

```bash
archupdate [-h|--help] [-f|--full] [-b|--basic] [-o|--other] [-p|--post]
```

The available options are:

-h or --help: Display usage information and exit.
-f or --full: Update and clean all supported system components.
-b or --basic: Perform preupdate functions, then update only system-level packages.
-o or --other: Update non-system packages (those not included in the basic update).
-p or --post: Perform cleaning functions, which are included in the full update but not the basic update.

**dependencies:** `pacman` (always there on Arch), `reflector`, `fwupdmgr`, `paru`, `pacman-contrib`, `neovim` with vim-plug (see my dotfiles)

Note: much of this could be accomplished with pacman hooks but not all of this concerns `pacman` and other updaters could be added in the future. Power check is there because I've had major system corruption more than once due to a failing battery cutting power in the middle of firmware and/or kernel updates. Fixing these can be a huge pain, that part can be deleted if it's not applicable to your setup.

## backup

A bash script that uses `rsync` to copy directories from a specified source to a destination backup drive. The script is intended to be called by a Systemd user service. For an example see my dotfiles here:

### Configuration

To configure the script, you will need to set the following variables:

- HOME: The path to the home directory of the user whose directories you want to backup. Make sure to include a trailing slash.
- DEST: The path to the destination backup drive. This should be a directory on a separate drive or device where you want to store the backups. Make sure to include a trailing slash.

The script also includes an array of directories (BackupList) that you want to include in the backup. You can customize this array by adding or removing directories as needed.

- dependency: `rsync` (can also be switched to `rclone` with some modification for cloud drives

## chill

uses `youtube-dl` with `mpv` to stream music from youtube.

### Usage

```bash
chill [-h|--help] [-v|--version] [-l|--lofi] [-p|--piano] [-s|--social]
```

The available options are:

    -h or --help: Display usage information and exit.
    -v or --version: Display the script version and exit.
    -l or --lofi: Play lofi beats using mpv.
    -p or --piano: Play relaxing piano music using mpv.
    -s or --social: Play social network music using mpv.

-**dependencies**: `youtube-dl`, `mpv`

Note: The script uses YouTube URLs to play the music. Make sure you have an internet connection before running the script. The mpv player will automatically play the music at a volume of 50%. You can adjust the volume by modifying the --volume parameter in the script.

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

- usage: just `gourcegif` inside a git repo.

- **dependencies**:

  - gource: A version control visualization tool that can create visualizations of Git repositories.
  - ffmpeg: A multimedia framework that can be used to encode, decode, and manipulate audio and video files.
  - convert: A command-line image manipulation utility that is part of the imagemagick suite.

Note: The script uses the --key and --highlight-users options with gource to display the names of users who have made changes to the repository, and the --seconds-per-day and --auto-skip-seconds options to control the speed of the visualization. You can adjust these options as needed to customize the visualization.

The script also uses the -600x500 option with gource to set the size of the visualization, and the -r 60 and --fps=10 options with ffmpeg to control the frame rate of the resulting GIF. You can adjust these options to change the size and frame rate of the GIF as needed.

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
