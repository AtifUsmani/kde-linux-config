# Arch Setup & Dotfiles

Personal Arch Linux bootstrap + configs.

Used to quickly reproduce my environment on new machines.

---

## Usage

```bash
mkdir -p ~/.cache
git clone https://github.com/AtifUsmani/kde-linux-config ~/.cache
cd ~/.cache/kde-linux-config
chmod +x setup.sh
./setup.sh
````

---

## After Install

* Log out/in for KDE configs
* Run `p10k configure` if needed
* Set wallpaper manually
* Restore any secrets (SSH keys, tokens)

---

## Notes

* Script is interactive and safe to rerun
* Tested in Docker before running on host
* KDE configs live in `.config` and `.local`

---

## Devlopment

```bash
sudo pacman -S docker-buildx

sudo DOCKER_BUILDKIT=1 docker build -t arch-test .

sudo docker run -it arch-test
```

## TODO

* Maybe migrate to GNU Stow
* Add backup script