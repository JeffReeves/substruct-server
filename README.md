# substruct-server
Network boot server for substruct

## Install

These are the manual steps needed to configure the server, based on OS.

### Ubuntu 20.04

Install the TFTP, HTTP, NFS, and DHCP servers:

```sh
sudo apt-get install tftpd-hpa nginx isc-dhcp-server
```

Install SYSLINUX, PXELINUX, and iPXE:

```sh
sudo apt-get install syslinux pxelinux 
```

Make `/tfptboot` directory and copy pxelinux and syslinux files into it:

```sh
sudo mkdir /tftpboot
sudo cp /usr/lib/PXELINUX/pxelinux.0                /tftpboot
sudo cp /usr/lib/PXELINUX/lpxelinux.0               /tftpboot
sudo cp /usr/lib/syslinux/modules/bios/ldlinux.c32  /tftpboot
sudo cp /usr/lib/syslinux/modules/efi64/ldlinux.e64 /tftpboot
sudo cp /usr/lib/syslinux/modules/efi64/libutil.c32 /tftpboot
sudo cp /usr/lib/syslinux/modules/efi64/menu.c32    /tftpboot
sudo cp /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi    /tftpboot
```

Configure TFTPD via `/etc/default/tftpd-hpa`:

```
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/tftpboot"
TFTP_ADDRESS=":69"
TFTP_OPTIONS="--secure"
```

