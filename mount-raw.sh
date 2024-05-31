#!/bin/bash
apt update
apt install -y losetup mount
losetup -fP /file.raw
mount /dev/loop0 /mnt
tail -f /dev/null
