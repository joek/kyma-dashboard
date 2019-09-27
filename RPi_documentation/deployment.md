# Raspberry Pi deployment

To faciliate running the dashboards in SAP Office, Raspbian image with kiosk-like display script has been prepared. You can also run the app without burning image.

## Setup from image

To run the dashboards from image, you'll need:

* Raspberry Pi (tested on model 3 B Revision a02082)
* SD Card (min 8 GB)
* Ready to install Raspbian image: [link](https://sap.sharepoint.com/:u:/r/sites/100093/Shared%20Documents/Product%20Corner/Knowledge%20Management/Office%20TV%20screen/rpi_dashboard_setup.zip?csf=1&e=tSjxhM)
* [ApplePi Baker v2](https://www.tweaking4all.com/hardware/raspberry-pi/applepi-baker-v2/) (or other SD card restore software)

Setup:

1. Insert your SD card to your laptop's card reader.
2. Use the "Restore" operation in ApplePi (or corresponding tool) to restore Raspbian image from .zip file from above.
Remember, you original SD card will be wiped!
3. After restore is finished, insert the card to your Raspberry Pi.
4. Plug Ethernet, display and power cables to RPi.
5. After booting to standard Raspbian Desktop, Chromium app with dashboards should start after a short while.

## Setup from scratch

You'll need:

* Raspberry Pi with standard Raspbian installed.

Setup:

1. On RPi, create file `dashboard.sh` (for ex. on Desktop) and insert the code:

```bash
SET DISPLAY=:0.0
$(/usr/bin/chromium-browser --no-sandbox --noerrdialogs --disable-infobars --kiosk dashboard.cfapps.eu10.hana.ondemand.com/social)
```

This script will run the dashboard.
2. You can now run the app manually (with `./<path>dashboard.sh`). To autorun the app with RPi boot, add file in `/home/<RPi user, 'Pi' by default>/.config/autostart` directory:

```bash
nano /home/pi/.config/autostart/run-dashboard.desktop
```

And insert the content:

```bash
[Desktop Entry]
Type=Application
Name=Dashboard
Exec=./<path to dashboard script>dashboard.sh
```

After boot, your RPi should show the dashboards.

## WiFi display

Both setups work with Ethernet cable. If you want to use wireless connection, you'll have to edit `/etc/wpa_supplicant/wpa_supplicant.conf` file (already present in image):

```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=<your 2-letter country code>

network={
    ssid="SAP-Corporate"
    key_mgmt=WPA-EAP
    scan_ssid=1
    mode=0
    pairwise=CCMP TKIP
    identity="<your email at SAP">
    password="<your password>"
    phase1="pealabel=0"
    phase2="auth=MSCHAPV2"
}

```

As you can see, this method uses your password, stored in plaintext, which is rather unfortunate. A better way is to create a technical user, or just use the Ethernet cable.
