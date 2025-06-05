# Debian Auto Installer

- MOTD
  - Edit file and delete all text in the file and save:\
  `sudo nano /etc/motd`

- Network Setup (Static IP)
  - Edit text in file and save:\
  `sudo nano /etc/network/interfaces`
    - Comment out:
    `allow-hotplug enp0s3
    iface enp0s3 inet dhcp`

- SSH Setup
