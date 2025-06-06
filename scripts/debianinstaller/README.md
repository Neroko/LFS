# Debian Auto Installer

---
> [!CAUTION]
> Nothing tested yet

## Auto Install Test Machine:
  VM Stats:</br>
  - Processor Cores = 8
  - Processor Feqz = 2.5 GB
  - Memory = 8 GB
  - UEFI = Disabled
  - Storage = 80 GB
  - Network = NAT

## Builder machince:

## After Auto Installer:
- [ ] Needed Packages:
  ```
  sudo apt update
  sudo apt upgrade
  sudo apt install \
    tmux \
    htop \
    ssh 
  ```
  - [ ] TMUX config file (.tmux.conf):
    ```
    # Reload config file (change file location to your tmux.conf file)
    bind r source-file ~/.tmux.conf \; display "Reloaded"

    # Enable mouse control (clickable windows, panes, resizable panes)
    set -g mouse on

    # Set statas bar refrest rate
    set -g status-interval 1

    # Set time in status bar to 12H EST
    set -g status-right '#(TZ="America/New_York" date +"%m-%d-%Y %I:%M:%S%p ")'
    ```

- [ ] GRUB
  - Dont show yet

- [ ] MOTD
  - Edit file and delete all text in the file and save:\
  `sudo nano /etc/motd`

- [ ] Network Setup (Static IP)
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
    - Set `enp0s3` to your network device<br/>
    - Set network `address/netmask/gateway/dns-nameservers` to your networks setttings
    - Shutdown system:
    ```
    sudo shudown how -n
    ```
    - In VM settings, change network from "NAT" to "Bridged Adapter"

- [ ] SSH Setup
