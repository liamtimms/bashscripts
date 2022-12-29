# Liam's simple bash scripts

These are basic quality of life bash scripts for things I do regularly.

To install most dependencies on Arch run:

    sudo pacman -S --needed pacman-contrib fwupdmgr rclone pandoc neovim reflector fzf

Paru must be manually installed if you haven't already installed it. `gnome-pomodoro` can be installed with the PKGBUILD from the AUR (where I'm the current maintainer of the PKGBUILD).

Before running any script with rclone, you need to configure it to use your cloud drive of choice.

This README contains top level header sections for a few longer and more complex scripts then a top level heading collecting information on the smaller scripts, a heading for a few scripts which worked in concert for producing my phd thesis and presentation, and finally on the scripts that remain WIPs for now. Online you can easily navigate to the sections using github's default table of contents accessed by hitting the hamburger menu in the upper left of this README display.

# pac

`pac` is a tiny but powerful wrapper for `fzf` and `pacman` which allows you to interacively search for, select, and manage packages installed on your machine or from the official Arch Linux repositories. It is both simple and extremely powerful by leveraging core utils, fzf features, and pacman's many flags. It enables selection of multiple packages to install or uninstall or print the info of selected installed packages.

### Usage

To use the script, with the flaag for your intent:

```bash
pac [-h|--help] [-v|--version] [-s|--install] [-r|--uninstall] [-q|--info]
```

The available options are:

    -h or --help: Display usage information and exit.
    -v or --version: Display the script version and exit.
    -s or --install: Search for and select packages from the official Arch repos to install
    -r or --uninstall: Select installed packages to uninstall.
    -q or --info: Select an installed package and display it's pacman database information.

Run the script and you will be presented with a search interface powered by fzf. Begin typing the name of the package(s) you want to (un)install, and use the space bar to preview information about packages. To select multiple packages flag them with by hitting Tab. When you have selected the package(s) you want, press Enter to pass the selection to pacman.

### Customization

You can customize the behavior of the fzf search windows by modifying the \_fzf_flags variable at the top of the script. For example, you can change the --ansi flag to --no-ansi to disable ANSI color output, or you can add the --reverse flag to reverse the order of the search results. Consult the fzf documentation for a full list of options.

# archupdate

## Features

Script designed to updates on my entire Arch linux install and setup. To that end it has 4 phases: 1. pre-update tasks, 2. system updates, 3. component updates, 4. post-update tasks

### Pre-update

Things to make updating go smoothly.

1. checks if the system is on AC power to avoid power loss during the process (which could lead to system failure)
2. refreshes the list of Arch servers so that package updates are delivered from fast, online and up to date servers if the current mirror list is old
3. checks for and prints news from ArchLinux.org (which may one's affect decision to update further)

### System Update

Changes to system-wide packages from the repositories and AUR.

1. updates official Arch packages
2. generates `paru`'s local database
3. does a full refresh of the local `pacman` database (to account for updated mirror list)
4. updates all official Arch Linux packages
5. builds and updates all AUR packages

### Component Updates

Changes to local plugins and environments.

1. pulls changes to my local copy of this bash script repo
2. updates the user level rust packages (the toolchain itself is updated as a system package)
3. updates `rust` modules managed by `rustup` (but not the rust toolchain itself which is managed by `pacman`)
4. checks for firmware updates for any connected hardware, updates firmware with `fwupdmgr` where possible
5. updates neovim plugins, updates CoC neovim packages, updates neovim Treesitter language parsers
6. updates `tmux` plugins
7. updates `systemd-boot` bootloader if applicable
8. updates Anaconda python distribution `base` environment

### Post-update

Steps to clean-up the system.

1. cleans the `pacman` cache keeping the latest 3 downloaded versions of each package
2. cleans the `paru` cache, trashing old source tarballs and built packages after 14 days
3. cleans unused `tmux` and neovim plugins
4. uses `pacdiff` with neovim to allow comparison between existing configuration files and new configuration files delivered by step 2 (saved with `.pacnew` extension)

### Usage

Different phases of the script are exposed through the options:

```bash
archupdate [-h|--help] [-f|--full] [-b|--basic] [-o|--other] [-p|--post]
```

The available options are:

    -h or --help: Display usage information and exit.
    -f or --full: Do all supported tasks (pre-update, system update, component updates, cleaning).
    -b or --basic: Deal with preupdate tasks, then update only system-level packages.
    -o or --other: Update non-system packages (those not included in the basic update).
    -p or --post: Perform cleaning functions (usually done at the end of full update).

**dependencies:** `pacman`, `reflector`, `fwupdmgr`, `paru`, `pacman-contrib`, `neovim` with vim-plug (see my dotfiles), `tmux` with tmux-plugin-manager, anaconda python user installation with a base environment

Note: much of this could be accomplished with pacman hooks but not all of this concerns `pacman` and other updaters could be added in the future. Power check is there because I've had major system corruption more than once due to a failing battery cutting power in the middle of firmware and/or kernel updates. Fixing these can be a huge pain, that part can be deleted if it's not applicable to your setup.

# backup

Uses `rsync` to copy directories from a specified source to a destination backup drive. The script is intended to be called by a Systemd user service. For an example see my dotfiles here: https://github.com/liamtimms/configs/blob/master/systemd/user/rsync-backup.service

## Configuration

To configure the script, you will need to set the following variables:

- HOME: The path to the home directory of the user whose directories you want to backup. Make sure to include a trailing slash.
- DEST: The path to the destination backup drive. This should be a directory on a separate drive or device where you want to store the backups. Make sure to include a trailing slash.

The script also includes an array of directories (BackupList) that you want to include in the backup. You can customize this array by adding or removing directories as needed.

- **dependencies**: `rsync` (can also be switched to `rclone` with some modification for cloud drives)

# chill

uses `youtube-dl` with `mpv` to stream music from youtube.

- **usage:**

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

## notes

If no filename is specified, the script will present a list of existing markdown files in the notes directory and allow the user to select a file to edit. If a filename is specified, the script will create a new markdown file with that name if it does not already exist with boilerplate from the script, or open the existing file for editing using the `$EDITOR` envornmental variable.

- **usage:** `notes <NameOfaNewNote>` or just use `notes` to select from a list of existing notes
- **configuration**: you'll want to edit the boiler it puts in new notes since that has my name in it and may also wish to change the default location of the `notes` directory.
- **dependencies:** `fzf`,

## pdfpreview

Converts Markdown to pdf on each save to preview a document.

- usage: `pdfpreview <markdownFile.md>`
- dependencies: `pandoc`, `entr`, `zathura`

## screenshots

## word2md

Converts a Microsoft Word document to Markdown, puts the figures in a folder. Just wraps pandoc with some nice options.

- usage: `word2md <markdownFile.md>`
- dependencies: `pandoc`

# Tiny Scripts

These are little scripts which need minimal documentation and are just barely above the complexity of a bash alias. (less than 20 lines)

## goodmorning

Greets the user in the morning, displays weather for 5 minutes (get coffee!), then starts `gnome-shell-pomodoro` and opens a file called `~/Documents/notes/todo.md` using the `notes` script here.

- usage: `goodmorning`,
- dependencies: the `notes` script, `gnome-pomodoro`, `espeak`

## gourcegif

Creates a gif from git history.

- **usage:** just `gourcegif` inside a git repo.

- **dependencies**:

  - `gource`: A version control visualization tool that can create visualizations of Git repositories.
  - `ffmpeg`: A multimedia framework that can be used to encode, decode, and manipulate audio and video files.
  - `convert`: A command-line image manipulation utility that is part of the `imagemagick` suite.

Note: The script uses the `--key` and `--highlight-users` options with gource to display the names of users who have made changes to the repository, and the `--seconds-per-day` and `--auto-skip-seconds` options to control the speed of the visualization. You can adjust these options as needed to customize the visualization.

The script also uses the `-600x500` option with `gource` to set the size of the visualization, and the `-r 60` and `--fps=10` options with ffmpeg to control the frame rate of the resulting GIF. You can adjust these options to change the size and frame rate of the GIF as needed.

## imageextract

This bash script is a tool for extracting images from PDF files and saving them to a specified directory. It also converts the PDF to text and saves the text to a separate file in the output directory.

- **usage:**

```bash
imageextract [input directory] [output directory]
```

The script will extract images from all PDF files in the input directory, save the images to the output directory, and convert the PDFs to text and save the text files to the output directory.

- **dependencies:** `pdfimages`, `pdftotext`

On Arch these are both included in the `poppler` package.

## module-update

Backend for a way-bar status update indicator in swaywm. I am not currently using sway or waybar but the relevant config can be found here: https://github.com/liamtimms/configs/blob/master/waybar/config#L62

## newscript

Takes a filename, makes a new bash script file in the current directory with the given name and makes it executable. I use this whenever I'm making a new script to skip boiler plate.

- **usage:** `newscript <NameOfaScriptYouWantToMake>`

## picinpic

Plays a video using the MPV media player. It takes one argument, the source file to be played, and displays the video in the corner of the screen with the size automatically adjusted to fit within an 800 pixel width. The video is also set to stay on top of other windows. If no source file is provided, the script will display a usage message and exit.

- **usage:** `picinpic <videofile>`
- **dependencies:** `mpv`

## presentation

Takes markdown file and converts it to a pdf document (`filename_notes.pdf`) and a pdf slide show (`filename_slides.pdf`). Note that the markdown is carefully broken up by headers and subheaders there is a high likelyhood of text and images overflowing on the slides. For info about structuring a markdwon file for use with pandoc for slide shows see: https://pandoc.org/MANUAL.html#slide-shows

- **usage:** `presentation <markdownfile>`
- **dependencies:** `pandoc`

## screenshots

Takes screenshots using the gnome-screenshot command and saves them in the ~/Pictures/Screenshots directory with a filename that includes the current date and time. The script will take a screenshot every two minutes indefinitely, until it is interrupted with the CTRL+Z key combination. This is useful for creating time lapse videos of long projects.

- **usage**: `screenshots`
- **dependencies**: using the GNOME desktop
- **configuration:** one can very easily switch out the screenshot tool for one like `scrot` if not on GNOME

./word2md
./md2word

## imgopt

Losslessly optimizes images in a directory using 6 parallel threads. It first searches for JPEG and PNG files using the fd command and then uses parallel to optimize them with jpegoptim and optipng, respectively. This lowers files size without reducing image quality.Note PNG optimization can be very time and computation intensive.

- **usage:** `imgopt` inside a directory with images (rescursively searches to find all)
- **dependencies:** `fd`, `optipng`, `jpegoptim`

## mounts

Just uses `sshfs` to mount some common directories for me. Essentially just an alias.

- **usage:** `mounts` on my network
- **dependencies:** `sshfs`

## vnc_start

Sets up `ssh` tunnel and connects it to `vnc` to activate a GUI view on my headless machine.

- **usage:** `vnc_start` on my network
- **dependencies:** `ssh`, `vncviewer`

## extract_dcm_info

This script reads a directory of DICOM files and extracts information from them. It creates two files for each directory of DICOM files: a file containing the DICOM header and a file containing the CSA header. The files are placed in a "headers" directory and are named using the original directory name. The script uses the gdcmdump tool to extract the information.

- **usage:** `extract_dcm_info` inside a directory with .ima or .dcm files.
- **dependencies:** `gdcmdump` which is included in the `gdcm` DICOM c++ library

## idk

Gathers a few sources for quick info on commands and programs. _Actually one of my most useful little scripts_ I use it constantly to check cli options.

- **usage:** `idk <program>` then hit `y` to step through more information.

- **dependencies:** `man-db` which provides both the `whatis` and `man` commands

## journal

Create and edit a daily journal in markdown format. The journal is saved in the ~/Documents/notes/journal directory, with the filename being the current date in the format YYYY-MM-DD.md.

If the journal file for the current date already exists, the script will open it in the `$EDITOR` default editor you choose by setting that envornmental variable. If the file does not exist, the script will create it and insert a template for the journal entries, including sections for completed tasks, uncompleted tasks, and reflections and goals for the next day.

Note: for my current setup, this script has been superceded by Vimwiki and is no longer in use.

- **usage:** `journal` from anywhere on your system
- **configuration:** make sure you are happy with the journal path and change the author name if you use this.
- **dependencies**: just set the `$EDTIOR` environmental variable.

# Scripts Related to Writing My PhD Thesis (and Papers)

These scripts were used primarily for producing my phd thesis. However, they can be adpated for other uses or be instructional for writing your own approaches.

## gitpaper

Script is designed to help with version control when working with markdown files. It takes a single markdown file as input and processes it to create a new file with each sentence on a new line. This can make it easier to track changes in Git, as each sentence will be treated as a separate line for the purpose of version control.

To use the script, simply run it with the path to the input markdown file as the argument. The output file will be created in the same directory as the input file, with "\_git.md" appended to the filename. The script also uses the `entr` utility to continuously monitor the input file for changes and update the output file accordingly. This can be helpful if you are actively editing the input file and want to see the changes reflected in the output file in real-time.

./gitpaper
./thesis_combine
./thesis_make
./present_combine

# Work-In-Progress Scripts

## gdrive

Implementing `git` like syntax for interacting with google drive. I am not currently using this since newer versions of Nautilus have usable google drive support built in.

- usage: implements easier syntax for rclone, including cloning from google drive, pulling updates from google drive, and pushing new files to google drive
- dependencies: `rclone` configured for google drive

## goodnight

Place-holder. I've got ideas but too inconsistent in the evening.
