# Linux image with these dotfiles: Ubuntu 24.04, zsh + oh-my-zsh + powerlevel10k,
# tmux, helix, fzf/zoxide/gh/bun, and every package stowed (linux/setup.sh).
# Build from the repo root; it copies this checkout (uncommitted changes included):
#   docker build -f linux/Dockerfile -t dotfiles .
#   docker run --rm -it dotfiles
# herdr-box builds its image on top of this one.
FROM ubuntu:24.04
ARG USER=david
ENV LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive
# The stock `ubuntu` account holds uid 1000; give it to $USER instead.
RUN apt-get update \
    && apt-get install -y --no-install-recommends sudo ca-certificates curl git \
    && rm -rf /var/lib/apt/lists/* \
    && userdel -r ubuntu \
    && useradd -m -u 1000 -s /bin/bash "$USER" \
    && echo "$USER ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/dotfiles \
    && chmod 440 /etc/sudoers.d/dotfiles
# Also at /opt/dotfiles (root-owned, world-readable): images built on this one seed
# homes that predate it from there, whatever has been pushed.
COPY . /opt/dotfiles
COPY --chown=1000:1000 . /home/$USER/projects/dotfiles
USER $USER
WORKDIR /home/$USER
RUN projects/dotfiles/linux/setup.sh \
    && sudo usermod -s /usr/bin/zsh "$USER" \
    && sudo rm -rf /var/lib/apt/lists/*
CMD ["zsh", "-l"]
