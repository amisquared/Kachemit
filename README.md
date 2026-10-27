# Kachemit
~~timehack~~ Kachemit is a Plasmoid widget that shows you your Hackatime stats!

## Author's note
I am not in anyway familiar with QML, Plasmoids or anything KDE. This code will trigger you. Probably.

## Usage
Set your Hackatime API key in the configuration menu.
Your API key can be found via the Wakatime CLI or the dotfile.
```bash
$ ~/.wakatime/wakatime-cli --config-read api_key --config-section settings
0000000-0000-0000-0000-0000000
$ cat ~/.wakatime.cfg 
[settings]
api_url = https://.....
api_key = 0000000-0000-0000-0000-0000000
heartbeat_rate_limit_seconds = 30
```

## Install
```bash
$ git clone https://github.com/amisquared/Kachemit --depth 1 --single-branch
$ cd Kachemit
$ kpackagetool6 --type Plasma/Applet --install .
```

## Licensing
This project is licensed under the [GNU Affero General Public License (AGPLv3)](https://www.gnu.org/licenses/agpl-3.0.html).