# Debian Auto Installer

- Needed Packages:
  ```
  sudo apt update
  sudo apt upgrade
  sudo apt install tmux htop ssh 
  ```

- MOTD
  - Edit file and delete all text in the file and save:\
  `sudo nano /etc/motd`

- Network Setup (Static IP)
  - Edit text in file and save:\
  `sudo nano /etc/network/interfaces`
    - Comment out lines:\
    ```
    #allow-hotplug enp0s3
    #iface enp0s3 inet dhcp
    ```
    - Add under commented out lines:
    ```
    auto enp0s3
    iface enp0s3 inet static
      address 192.168.1.200
      netmask 255.255.255.0
      gateway 192.168.1.1
      dns-nameservers 192.168.1.1
    ```

- SSH Setup
