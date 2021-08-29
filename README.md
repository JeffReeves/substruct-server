# substruct-server
Network boot server for substruct

## Install - Ubuntu 20.04

### SYSLINUX and PXELINUX

Install SYSLINUX and PXELINUX:

```sh
sudo apt-get install syslinux pxelinux
```

### iPXE

Create a directory to store iPXE files and download them from the web:

```sh
mkdir ~/ipxe
curl http://boot.ipxe.org/undionly.kpxe --output ~/ipxe/undionly.kpxe
curl http://boot.ipxe.org/ipxe.efi      --output ~/ipxe/ipxe.efi
```

Or build iPXE from source for any additional features (such as graphical backgrounds):

- [Official iPXE Build Instructions](https://ipxe.org/appnote/buildtargets)

### TFTP

Install the TFTP server:

```sh
sudo apt-get install tftpd-hpa
```

Configure TFTPD via `/etc/default/tftpd-hpa`:

```conf
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/tftpboot"
TFTP_ADDRESS=":69"
TFTP_OPTIONS="--secure"
```

Make a `/tftpboot` directory with full permissions:

```sh
sudo mkdir      /tftpboot
sudo chmod 777  /tftpboot
```

Copy SYSLINUX, PXELINUX, and iPXE files into it:

```sh
sudo cp /usr/lib/syslinux/modules/bios/ldlinux.c32  /tftpboot
sudo cp /usr/lib/syslinux/modules/efi64/ldlinux.e64 /tftpboot
sudo cp /usr/lib/syslinux/modules/efi64/libutil.c32 /tftpboot
sudo cp /usr/lib/syslinux/modules/efi64/menu.c32    /tftpboot
sudo cp /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi    /tftpboot
sudo cp /usr/lib/PXELINUX/pxelinux.0                /tftpboot
sudo cp /usr/lib/PXELINUX/lpxelinux.0               /tftpboot
cp      ~/ipxe/ipxe.efi                             /tftpboot
cp      ~/ipxe/undionly.kpxe                        /tftpboot
```

Make the `/tftpboot/pxelinux.cfg` directory to store boot menus:

```sh
sudo mkdir /tftpboot/pxelinux.cfg
sudo touch /tftpboot/pxelinux.cfg/default
```

Start and enable TFTPD:
```sh
sudo systemctl enable  tftpd-hpa
sudo systemctl restart tftpd-hpa
```

### DHCP

Install the DHCP server:

```sh
sudo apt-get install isc-dhcp-server
```

Edit the `/etc/dhcp/dhcpd.conf` file to include PXE booting options:

*NOTE: Replace the IP address `192.168.1.3` with your server's IP address*

```conf
# PXE BOOTING
#option space pxelinux;
#option pxelinux.magic code 208 = string;
#option pxelinux.configfile code 209 = text;
#option pxelinux.pathprefix code 210 = text;
#option pxelinux.reboottime code 211 = unsigned integer 32;
#option architecture-type code 93 = unsigned integer 16;

option client-architecture code 93 = unsigned integer 16;
if exists user-class and option user-class = "iPXE" {
    filename "http://192.168.1.3/ipxeroot/bootstrap.ipxe";
} elsif option client-architecture = 00:00 {
    filename "undionly.kpxe";
} else {
     filename "ipxe.efi";
}
next-server 192.168.1.3;
```

Start and enable the DHCP server:
```sh
sudo systemctl enable  isc-dhcp-server
sudo systemctl restart isc-dhcp-server
```

### Nginx

Install the web server:

```sh
sudo apt-get install nginx
```

Delete the default website:
```sh
sudo rm /etc/nginx/sites-available/default
```

Create a new website file:
```sh
sudo vim /etc/nginx/sites-available/substruct
```

Place this content inside of the file to define an HTTP server:

```conf
# HTTP - PORT 80
server {
    listen         80;
    listen         [::]:80;
    server_name    substruct;
    server_tokens  off;
    root           /var/www/substruct;
    index          index.html;

    # redirect to HTTPS
    #return 301 https://$server_name$request_uri;

    location / {
        autoindex    on;
        try_files    $uri $uri/ =404;
    }

    access_log     /var/log/nginx/substruct.log;
    error_log      /var/log/nginx/substruct.error.log;
}
```

Create the root web directory:
```sh
sudo mkdir -p /var/www/substruct
```

Start and enable the HTTP server:
```sh
sudo systemctl enable  nginx
sudo systemctl restart nginx
```

## Mount and Copy Operating Systems for Network Booting

### RHEL 8 DVD ISO
```sh
sudo mkdir /mnt/rhel8-install/
sudo mount -o loop,ro -t iso9660 ~/Downloads/rhel8/rhel-8.4-x86_64-dvd.iso /mnt/rhel8-install/
```



## Configure Raspberry Pi 4 (RPi4)

The Raspberry Pi 4 uses eeprom to network boot.

To enable network booting:

1. Copy the official Raspberry Pi OS (formerly "Raspbian") to an SD card.
2. Boot the RPi4 and open a terminal.
3. Update all packages: `sudo apt-get update && sudo apt-get dist-upgrade -y`.
4. Install the eeprom updater: `sudo apt-get install rpi-eeprom`.
5. Update eeprom: `sudo rpi-eeprom-update`.
6. Reboot: `sudo sync && sudo reboot`.
6. Set `BOOT_ORDER=0xf421` and `TFTP_PREFIX=2` with: `sudo -E rpi-eeprom-config --edit`.

*NOTE: The `TFTP_PREFIX=2` option makes it so that the `/tftpboot` directory uses RPi MAC address values instead of serial numbers.*

See the official documentation located here for further details:
- [Raspberry Pi 4 boot EEPROM](https://www.raspberrypi.org/documentation/hardware/raspberrypi/booteeprom.md)
- [Network booting](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/net.md)
- [Raspberry Pi 4 Bootloader Configuration](https://www.raspberrypi.org/documentation/computers/raspberry-pi.html#raspberry-pi-4-bootloader-configuration)

To network boot an entire Raspberry Pi OS, see the official tutorial here:
- [Network boot your Raspberry Pi](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/net_tutorial.md)