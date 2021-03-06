# connmon
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/91af8db9cd354643a8ef6a7117be90fb)](https://www.codacy.com/app/jackyaz/connmon?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=jackyaz/connmon&amp;utm_campaign=Badge_Grade)
![Shellcheck](https://github.com/jackyaz/connmon/actions/workflows/shellcheck.yml/badge.svg)

## v2.11.6
### Updated on 2021-06-21
## About
connmon is an internet connection monitoring tool for AsusWRT Merlin with charts for daily, weekly and monthly summaries.

connmon is free to use under the [GNU General Public License version 3](https://opensource.org/licenses/GPL-3.0) (GPL 3.0).

### Supporting development
Love the script and want to support future development? Any and all donations gratefully received!

[**PayPal donation**](https://paypal.me/jackyaz21)

[**Buy me a coffee**](https://www.buymeacoffee.com/jackyaz)

## Supported firmware versions
You must be running firmware Merlin 384.15/384.13_4 or Fork 43E5 (or later) [Asuswrt-Merlin](https://www.asuswrt-merlin.net/)

## Installation
Using your preferred SSH client/terminal, copy and paste the following command, then press Enter:
```sh
/usr/sbin/curl --retry 3 "https://raw.githubusercontent.com/jackyaz/connmon/master/connmon.sh" -o "/jffs/scripts/connmon" && chmod 0755 /jffs/scripts/connmon && /jffs/scripts/connmon install
```

## Usage
### WebUI
connmon can be configured via the WebUI, in the Addons section.

### Command Line
To launch the connmon menu after installation, use:
```sh
connmon
```

If this does not work, you will need to use the full path:
```sh
/jffs/scripts/connmon
```

## Screenshots
![WebUI](https://puu.sh/HACve/5abb816c02.png)

![CLI UI](https://puu.sh/HACv1/ec4e09211b.png)

## Help
Please post about any issues and problems here: [Asuswrt-Merlin AddOns on SNBForums](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=18)
