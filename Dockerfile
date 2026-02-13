FROM archlinux:latest

# Update & base tools
RUN pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman -Syu --noconfirm && \
    pacman -S --noconfirm sudo git base-devel curl

# Create user
RUN useradd -m tester && \
    echo "tester ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER tester
WORKDIR /home/tester

# Copy your repo into container
COPY --chown=tester:tester . /home/tester/setup
WORKDIR /home/tester/setup

CMD ["bash"]