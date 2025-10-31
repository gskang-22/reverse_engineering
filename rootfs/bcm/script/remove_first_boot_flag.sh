# work with swdl_init.sh. used to remove first_boot_flag.
# xufuguo, 2014.03.07

if [ -f /tmp/software_download/last_buildinfo_img* ]; then
  echo "SWDL: will remove first_boot_flag in 60s"
  sleep 60  # wait for all first boot action done
  mv /tmp/software_download/last_buildinfo_img* /configs/swdl/
  sync
  echo "SWDL: remove first_boot_flag done"
fi
