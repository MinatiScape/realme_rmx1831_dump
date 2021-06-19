#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/platform/bootdevice/by-name/recovery:35115856:a21bb81b4ea79b93ffcfaf4ba30521cbae0b2a3e; then
  applypatch  EMMC:/dev/block/platform/bootdevice/by-name/boot:9931600:62867c149a7c927265a6e77f129b9f9e48b4a5c9 EMMC:/dev/block/platform/bootdevice/by-name/recovery a21bb81b4ea79b93ffcfaf4ba30521cbae0b2a3e 35115856 62867c149a7c927265a6e77f129b9f9e48b4a5c9:/system/recovery-from-boot.p && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
