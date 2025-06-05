# Debian Auto Installer

---
> [!WARNING]
> Nothing have been tested yet.
---

TODO:
- [ ] Install basic Debian system to make custom Debian build
- [ ] Install needed packages and setup system (Network/Remote/HDD/etc..)

## Auto Install:
Testing in VM
  Stat:</br>
  - Processor CPUs = 8 Cores
  - Memory = 8 GB
  - UEFI = Disabled
  - Storage = 80 GB

## After Auto Installer:
- Needed Packages:
  ```
  sudo apt update
  sudo apt upgrade
  sudo apt install \
    tmux \
    htop \
    ssh 
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
    - Set `enp0s3` to your network device<br/>
    - Set network `address/netmask/gateway/dns-nameservers` to your networks setttings

- SSH Setup
