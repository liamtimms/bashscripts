FROM nvidia/cuda:12.2.2-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    # C++ toolchain
    build-essential cmake ninja-build clang clangd gdb \
    libboost-all-dev libeigen3-dev libgtest-dev libfmt-dev \
    # Scientific / imaging
    libhdf5-dev libfftw3-dev libnifti-dev libopencv-dev dcm2niix \
    # Python
    python3 python3-pip python3-venv \
    # CLI tools
    git ripgrep fd-find fzf curl wget jq neovim ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# fd-find installs as fdfind on Ubuntu; alias it
RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd
