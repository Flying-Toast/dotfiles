# Installation
- In a tty (**cannot** be in a terminal emulator within sway): `sudo ./fedora.sh && ./install.sh`
- `printf "APP SPECIFIC PASSWORD" | secret-tool store --label=mutt key mutt`
- `printf "APP SPECIFIC PASSWORD" | secret-tool store --label=isync key isync`
- `printf "APP SPECIFIC PASSWORD" | secret-tool store --label=calcurse key calcurse`
- `calcurse-caldav --init keep-remote`
