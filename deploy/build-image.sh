#!/bin/bash
# Build SD card image for Raspberry Pi 5

set -e

# Build the RPi5 image using nix-build
nix-build -A rpi5Image

# Flash the image to SD card
# Replace /dev/sdX with your actual SD card device
dd if=result/img/boot.sdcard.gz | gunzip | dd of=/dev/sdX bs=4M status=progress

echo "SD card image built and flashed successfully"