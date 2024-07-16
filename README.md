# piper-switcher
Automatically switch Piper profiles based on active window on Linux (like G Hub on Windows)

# Requirements

- Piper
- xdotool
- [x11_watch_active_window.py](https://gist.github.com/dperelman/c1d3c966d397ff884abb8b3baf7990db)
	+ xlib python library

Note: `xdotool` and `x11_watch_active_window.py` must be available on the `$PATH`

# Installation

1. Download the `Source code` of the latest relaese
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
