# Liam's simple bash scripts

These are basic quality-of-life bash scripts for things I do regularly.

This README contains top-level header sections for a few longer and more complex scripts, then a top-level heading collecting information on the smaller scripts, a heading for a few scripts which worked in concert for producing my PhD thesis and presentation, and finally on the scripts that remain WIPs for now. You can easily navigate the sections online using github's default table of contents accessed by hitting the hamburger menu in the upper left of this README display.

Each script includes information about its usage and dependencies. But to install most dependencies from official repositories on Arch Linux, run:

```bash
sudo pacman -S --needed entr espeak-ng fd ffmpeg fwupd fzf imagemagick jpegoptim man-db mpv neovim optipng pacman-contrib pandoc poppler rclone reflector rsync ssh sshfs tmux tigervnc xdg-utils youtube-dl
```

Finally, [paru](https://github.com/Morganamilo/paru#installation) must be manually installed if you haven't already installed it. `gnome-shell-pomodoro` and `gdcm` can be installed from the AUR using `paru`.

# pac

`pac` is a tiny but powerful wrapper for `fzf` and `pacman`, which allows you to search for, select interactively, and manage packages installed on your machine or from the official Arch Linux repositories. It is simple yet extremely valuable by leveraging core utils, fzf features, and pacman's many flags. In addition, it enables the selection of multiple packages to install, uninstall, or print the info of selected, installed packages.

### Usage

To use the script with the flag for your intent:

```bash
pac [-h|--help] [-v|--version] [-s|--install] [-r|--uninstall] [-q|--info]
```

The available options are:

    -h or --help: Display usage information and exit.
    -v or --version: Display the script version and exit.
    -s or --install: Search for, and select packages from the official Arch repos to install
    -r or --uninstall: Select installed packages to uninstall.
    -q or --info: Select an installed package and display its pacman database information.

Run the script, and fzf will present you with a search interface. Begin typing the name of the package(s) you want to (un)install, and use the space bar to preview information about packages. To select multiple packages, flag them by hitting Tab. When you have set the package(s) you want, press Enter to pass the selection to pacman.

- **dependencies:** `fzf`, `pacman`

### Customization

You can customize the behavior of the fzf search windows by modifying the \_fzf_flags variable at the top of the script. For example, you can change the `--ansi` flag to `--no-ansi` to disable ANSI color output, or you can add the --reverse flag to reverse the order of the search results. Consult the fzf documentation for a complete list of options.

# archupdate

## Features

Script designed to update my entire Arch Linux install and setup. To that end, it has 4 phases: 1. pre-update tasks, 2. system updates, 3. component updates, and 4. post-update tasks.

### Pre-update

Things to make updating go smoothly.

1. checks if the system is on AC power to avoid power loss during the process (which could lead to system failure)
2. refreshes the list of Arch servers, so that package updates are delivered from fast, online, and up-to-date servers if the current mirror list is old
3. checks for and prints news from ArchLinux.org (which may one's affect decision to update further)

### System Update

Changes to system-wide packages from the repositories and AUR.

1. updates official Arch packages
2. generates `paru`'s local database
3. does a full refresh of the local `pacman` database (to account for the updated mirror list)
4. updates all official Arch Linux packages
5. builds and updates all AUR packages

### Component Updates

Changes to local plugins and environments.

1. pulls changes to my local copy of this bash script repo
2. updates the user-level rust packages (the toolchain itself is updated as a system package)
3. updates `rust` modules managed by `rustup` (but not the rust toolchain itself, which is managed by `pacman`)
4. checks for firmware updates for any connected hardware and updates firmware with `fwupdmgr` where possible
5. updates neovim plugins, updates CoC neovim packages, updates neovim Treesitter language parsers
6. updates `tmux` plugins
7. updates `systemd-boot` bootloader if applicable
8. updates Anaconda python distribution `base` environment

### Post-update

Steps to clean up the system.

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
    -b or --basic: Deal with pre-update tasks, then update only system-level packages.
    -o or --other: Update non-system packages (those not included in the basic update).
    -p or --post: Perform cleaning functions (usually done at the end of the full update).

- **dependencies:** `pacman`, `reflector`, `fwupd`, `paru`, `pacman-contrib`, `neovim` with vim-plug (see my dotfiles), `tmux` with tmux-plugin-manager, anaconda python user installation with a base environment

Note: much of this could be accomplished with pacman hooks, but not all of this concerns `pacman` and other updaters could be added in the future. The power check is there because I've had significant system corruption more than once due to a failing battery cutting power in the middle of firmware and/or kernel updates. Fixing these can be a huge pain; that part can be deleted if it does not apply to your setup.

# backup

Uses `rsync` to copy directories from a specified source to a destination backup drive. The script is intended to be called by a Systemd user service. For an example, see my dotfiles here: https://github.com/liamtimms/configs/blob/master/systemd/user/rsync-backup.service.

## Configuration

To configure the script, you will need to set the following variables:

- HOME: The path to the user's home directory whose directories you want to backup. Make sure to include a trailing slash.
- DEST: The path to the destination backup drive. This should be a directory on a separate drive or device where you want to store the backups. Again, make sure to include a trailing slash.

The script also includes an array of directories (BackupList) that you want to have in the backup. You can customize this array by adding or removing directories as needed.

- **dependencies**: `rsync` (can also be switched to `rclone` with some modification for cloud drives)

# chill

Uses `youtube-dl` with `mpv` to stream music from youtube.

## Usage

```bash
chill [-h|--help] [-v|--version] [-l|--lofi] [-p|--piano] [-s|--social]
```

The available options are:

    -h or --help: Display usage information and exit.
    -v or --version: Display the script version and exit.
    -l or --lofi: Play lofi beats using mpv.
    -p or --piano: Play relaxing piano music using mpv.
    -s or --social: Play social network music using mpv.

- **dependencies**: `youtube-dl`, `mpv`

Note: The script uses YouTube URLs to play the music. Make sure you have an internet connection before running the script. The mpv player will automatically play the music at a volume of 50%. You can adjust the volume by modifying the --volume parameter in the script.

## notes

If no filename is specified, the script will present a list of existing markdown files in the notes directory and allow the user to select a file to edit. If a filename is specified, the script will create a new markdown file with that name if it does not already exist with a boilerplate from the script or open the existing file for editing using the `$EDITOR` environmental variable.

- **usage:** `notes <NameOfaNewNote>` or just use `notes` to select from a list of existing notes
- **configuration**: you'll want to edit the boiler it puts in new notes since that has my name in it, and you may also wish to change the default location of the `notes` directory.
- **dependencies:** `fzf`,

# Tiny Scripts

These are little scripts that need minimal documentation and are just barely above the complexity of a bash alias. (less than 35 lines)

## gitbot

This bash script is designed to automatically update a specified list of Git repositories. It does this by first fetching the latest changes from the remote repository and then checking if the remote repository is ahead of the local repository. If the remote repository is ahead, the script does nothing. If the remote repository is not ahead, the script adds all changes in the local repository, commits the changes, and pushes the changes to the remote repository.

To use this script, edit the `Repos` array to specify the list of repositories that you want to update. The script will then iterate over each repository in the list, updating it as necessary. Note that the paths specified in the Repos array should be relative to the home directory (specified by the HOME variable) and include the trailing slash.

This script is intended to be run regularly (e.g., using a systemd user timer) to ensure that the specified repositories are always up to date. You can see my implementation of that here: https://github.com/liamtimms/configs/blob/master/systemd/user/gitbot.timer and https://github.com/liamtimms/configs/blob/master/systemd/user/gitbot.service.

## goodmorning

Greets the user in the morning, displays weather for 5 minutes (get coffee!), then starts `gnome-shell-pomodoro` and opens a file called `~/Documents/notes/todo.md` using the `notes` script here.

- **usage:** `goodmorning`,
- **dependencies:** the `notes` script, `gnome-shell-pomodoro`, `espeak-ng`

## gourcegif

Creates a gif from git history.

- **usage:** just `gourcegif` inside a git repo.

- **dependencies**:

  - `gource`: A version control visualization tool that can create visualizations of Git repositories.
    `ffmpeg`: A multimedia framework that encodes, decodes, and manipulates audio and video files.
  - `convert`: A command-line image manipulation utility that is part of the `imagemagick` suite.

Note: The script uses the `--key` and `--highlight-users` options with gource to display the names of users who have made changes to the repository, and the `--seconds-per-day` and `--auto-skip-seconds` options to control the speed of the visualization. You can adjust these options as needed to customize the visualization.

The script also uses the `-600x500` option with `gource` to set the size of the visualization and the `-r 60` and `--fps=10` options with ffmpeg to control the frame rate of the resulting GIF. You can adjust these options to change the size and frame rate of the GIF as needed.

## imageextract

This bash script is a tool for extracting images from PDF files and saving them to a specified directory. It also converts the PDF to text and saves the text to a separate file in the output directory.

- **usage:**

```bash
imageextract [input directory] [output directory]
```

The script will extract images from all PDF files in the input directory, save the images to the output directory, convert the PDFs to text and save the text files to the output directory.

- **dependencies:** `pdfimages`, `pdftotext`

On Arch, these are both included in the `poppler` package.

## module-update

Backend for a way-bar status update indicator in sway wm. I am not currently using sway or waybar, but the relevant config can be found here: https://github.com/liamtimms/configs/blob/master/waybar/config#L62.

## newscript

Takes a filename, makes a new bash script file in the current directory with the given name, and makes it executable. I use this whenever I'm making a new script to skip the boilerplate.

- **usage:** `newscript <NameOfaScriptYouWantToMake>`

## picinpic

Plays a video using the MPV media player. It takes one argument, the source file to be played, and displays the video in the corner of the screen with the size automatically adjusted to fit within an 800-pixel width. The video is also set to stay on top of other windows. If no source file is provided, the script will display a usage message and exit.

- **usage:** `picinpic <videofile>`
- **dependencies:** `mpv`

## presentation

Takes markdown file and converts it to a pdf document (`filename_notes.pdf`) and a pdf slide show (`filename_slides.pdf`). Note that the Markdown needs to be carefully broken up by headers and subheaders, there is a high likelihood of text and images overflowing on the slides. For info about structuring a markdown file for use with pandoc for slide shows, see https://pandoc.org/MANUAL.html#slide-shows.

- **usage:** `presentation <markdownfile>`
- **dependencies:** `pandoc`

## screenshots

Takes screenshots using the gnome-screenshot command and saves them in the ~/Pictures/Screenshots directory with a filename that includes the current date and time. The script will take a screenshot every two minutes indefinitely until it is interrupted with the CTRL+Z key combination. This is useful for creating time-lapse videos of long projects.

- **usage**: `screenshots`
- **dependencies**: `gnome-screenshot` (included if using the GNOME desktop)
- **configuration:** one can very easily switch out the screenshot tool for one like `scrot` if not on GNOME

## imgopt

Losslessly optimizes images in a directory using 6 parallel threads. It first searches for JPEG and PNG files using the fd command and then uses parallel to optimize them with jpegoptim and optipng, respectively. This lowers file size without reducing image quality. Note PNG optimization can be very time and computation intensive.

- **usage:** `imgopt` inside a directory with images (recursively searches to find all)
- **dependencies:** `fd`, `optipng`, `jpegoptim`

## mounts

Just uses `sshfs` to mount some common directories for me. Essentially just an alias.

- **usage:** `mounts` on my network
- **dependencies:** `sshfs`

## vnc_start

Sets up an `ssh` tunnel and connects it to `vnc` to activate a GUI view on my headless machine.

- **usage:** `vnc_start` on my network
- **dependencies:** `ssh`, `vncviewer`

## extract_dcm_info

This script reads a directory of DICOM files and extracts information from them. First, it creates two files for each directory of DICOM files: a file containing the DICOM header and a file containing the CSA header. The files are placed in a "headers" directory and are named using the original directory name. Then, the script uses the gdcmdump tool to extract the information.

- **usage:** `extract_dcm_info` inside a directory with .ima or .dcm files.
- **dependencies:** `gdcmdump`, which is included in the `gdcm` DICOM c++ library

## idk

Gathers a few sources for quick info on commands and programs. It is is one of my most useful little scripts. I use it constantly to check CLI program flags, options, and info.

- **usage:** `idk <program>` then hit `y` to step through more information.

- **dependencies:** `man-db`, which provides both the `whatis` and `man` commands

## journal

Create and edit a daily journal in markdown format. The journal is saved in the ~/Documents/notes/journal directory, with the filename being the current date in the format YYYY-MM-DD.md.

If the journal file for the current date already exists, the script will open it in the `$EDITOR` default editor you choose by setting that environmental variable. If the file does not exist, the script will create it and insert a template for the journal entries, including sections for completed tasks, uncompleted tasks, and reflections and goals for the next day.

Note: for my current setup, this script has been superseded by Vimwiki and is no longer in use.

- **usage:** `journal` from anywhere on your system
- **configuration:** make sure you are happy with the journal path and change the author name if you use this.
- **dependencies**: just set the `$EDTIOR` environmental variable.

## videomaker

Used to create a video from a series of images. The images are first cropped, and then a logo is added to each image. The resulting images are used to create a video using ffmpeg, which is then reversed and combined with a copy of itself to create a looping video.

- **usage:**

To use this script, make sure that you have the dependencies installed and that you have a series of images in the src directory. Then, simply run the script and provide the input file as the first argument and the output file as the second argument. The resulting video will be saved as output_together.mp4.

You'll need to adjust paths, file names, etc., but it can be a helpful starting point.

- **dependencies:** `mogrify` and `composite` (include in `imagemagick`), `ffmpeg`

## word2md

Converts a Microsoft Word document to Markdown and puts the figures in a folder. It just wraps pandoc with some nice options.

- **usage:** `word2md <wordfile.docx>`
- **dependencies:** `pandoc`

## md2word

Same as `word2md` but opposite direction.

- **usage:** `md2word <markdownFile.md>`
- **dependencies:** `pandoc`

# Scripts Related to Writing My PhD Thesis (and Papers)

These scripts were used primarily for producing my PhD thesis. However, they can be adapted for other uses or be instructional for writing your own approaches.

## pdfpreview

Allows you to quickly and easily convert a markdown file into a PDF using pandoc. It also includes an option to live-update the PDF preview as you change the markdown file.

- **usage:**

```bash
pdfpreview [-h|--help] [-t|--thesis] [-p|--paper] <markdown input file>
```

The available options are:

    -h or --help: Display usage information.
    -t or --thesis: Use pandoc with the short-captions filter to convert the markdown file into a PDF for use in a thesis document.
    -p or --paper: Use pandoc to convert the markdown file into a PDF for use in an article.

Example

To convert a markdown file called paper.md into a PDF for use in a paper, using the live update feature, run the following command:

./pandoc_live.sh -p paper.md

Converts Markdown to pdf on each save to preview a document.

- **dependencies:** `pandoc`, `entr`, `xdg-utils` to get the `xdg-open` command, a pdf viewer set as your xdg default

A live refreshing pdf viewer is recommended (`zathura` or Evince, AKA GNOME Document Viewer, work well). You can also switch out `xdg-open` for just saying `zathura` in the script.

## gitpaper

The script is designed to help with version control when working with markdown files. It takes a single markdown file as input and processes it to create a new file with each sentence on a new line. This can make it easier to track changes in Git, as each sentence will be treated as a separate line for version control.

The output file will be created in the same directory as the input file, with "\_git.md" appended to the filename. The script also uses the `entr` utility to continuously monitor the input file for changes and update the output file accordingly. This can be helpful if you are actively editing the input file and want to see the changes reflected in the output file in real time.

- **usage:** `gitpaper <somemarkdownfile>`
- **dependencies:** `entr`

## thesis_combine

This bash script is designed to continuously monitor a list of chapters specified in a file (`$inputfile`) and combine them into a single file (`$outputfile`) whenever any changes are made to the chapters. The script runs indefinitely, using the `entr` utility to check for changes in the chapters directory and execute the command to combine the chapters. The command uses cat to concatenate the chapters listed in `$list` and write the combined content to `$outputfile`. The script also displays a timestamp and message each time it updates the `$outputfile`.

- **usage:**

To use the script, one needs to have a set of individual markdown files for each chapter and then organize them in the desired order in the `$inputfile`. For example, you might make a file called `list_chapts.txt` which contains:

```markdown
chapters/introduction.md
chapters/methods.md
chapters/results.md
chapters/conclusions.md
```

The resulting document will preserve this order and update the output file whenever changes are made to any chapter.

- **dependencies:** `entr`

## thesis_make

Calls other thesis compilation and update scripts with appropriate options and files.

- **usage:** `thesis_make` inside a folder with a `list_chapts.txt` pointing to individual chapters
- **dependencies:** `gitpaper`, `thesis_combine`, `pdfpreview`

# Work-In-Progress Scripts

## gdrive

Implementing `git` like syntax for interacting with google drive. I am not currently using this since newer versions of Nautilus have usable google drive support built in.

- **usage:** implements more straightforward syntax for rclone, including cloning from google drive, pulling updates from google drive, and pushing new files to google drive
- **dependencies:** `rclone` configured for google drive

## goodnight

Place-holder.
