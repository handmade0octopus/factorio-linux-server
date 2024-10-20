# Factorio Linux Server
Simple factorio Linux server to run from single script.

It downloads latest factorio server or rebuilds from user provided setup. Then setups systemd for factorio and setups auto-update script to be run on timer.

`console.sh` lets you attach to Factorio console.

Has option for ZRAM folder for Factorio to make autosaves faster (HDD) and less disruptive and also slow the wear of SSD. Then it backups the whole server on each update script run.


# Installation
Rename `config.example.sh` to `config.sh` and adjust settings inside it.

Copy your factorio settings (preserving folder structure) into `factorio` folder.

Then run `./install.sh [param]` deafult `[param] = /opt/factorio` it also installs all dependencies, creates user and runs services.

After installation everything will work also on system restarts.

# Usage

Run `./console.sh` to access Factorio terminal. Exit quickly pressing `ESC+ESC+ESC`.


# Roadmap
- Add multiple servers support.
- Support other linux distributions.