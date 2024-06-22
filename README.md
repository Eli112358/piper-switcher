# piper-switcher
Automatically switch Piper profiles based on active window on Linux (like G Hub on Windows)

# Requirements

- Piper
- xdotool

# Installation

1. Download the `Source code (zip)` of the latest relaese
2. Unzip it
3. In your favorite text editor, fill out the `environment` file
4. Open a terminal in the directory of the extracted zip
5. Copy and paste the following code into the terminal
```bash
sudo mkdir /etc/piper-switcher.d
sudo mv environment /etc/piper-switcher.d
sudo mv piper-switcher.sh /usr/bin
sudo mv piper-swithcer.service /etc/systemd/system
sudo service piper-switcher enable
sudo service piper-switcher start
```
