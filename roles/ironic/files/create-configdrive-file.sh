### generate iso file

uuid=$1
prefix=`echo $uuid | awk -F- '{print $1}'`
mkisofs -R -V config-2 -o configdrive-$prefix.iso $uuid

gzip -c configdrive-$prefix.iso | base64 > configdrive-$prefix.iso.gz

rm -rf configdrive-$prefix.iso
