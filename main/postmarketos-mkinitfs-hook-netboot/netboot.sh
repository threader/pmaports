#!/bin/sh
# shellcheck disable=SC1091
. /etc/deviceinfo
. ./init_functions.sh
NBD_PORT=9999
NBD_IP=172.16.42.2
NBD_BLOCK_SIZE=${deviceinfo_rootfs_image_sector_size:-512}

setup_usb_network
start_unudhcpd

show_splash "Waiting for netboot..."

# Attempt to load the kernel module if CONFIG_BLK_DEV_NBD=m
modprobe nbd

# Check that we actually have nbd0 available, otherwise show an error screen.
if [ ! -b /dev/nbd0 ]; then
	echo "Failed to get /dev/nbd0, stopping."
	show_splash "Failed to initialise netboot"
	pmos_loop_forever
fi

while ! busybox nbd-client $NBD_IP $NBD_PORT /dev/nbd0 -b "$NBD_BLOCK_SIZE"; do
	echo "Connection attempt not successful, continuing..."
	sleep 1
done

echo "Connected to $NBD_IP!"

mount_subpartitions
