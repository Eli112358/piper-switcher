# piper-switcher
Automatically switch profiles based on active window (like G Hub) on Linux

# Installation

1. Download the latest relaese
2. Unzip it
3. In your favorite editor, edit shell script to replace user-specific details
4. Open a terminal in the directory of the extracted zip
5. In the terminal enter or copy/paste:
```bash
sudo mv piper-switcher.sh /usr/bin
sudo mv piper-swithcer.service /etc/systemd/system
sudo service piper-switcher enable
sudo service piper-switcher start
```
