#! /bin/bash
if [ -z "$2" ] || ( echo "$2" | grep -qv ':' ); then
  echo "Copies large number of small files efficiently over the network."
  echo -e "\tUsage: $0 source_dir dest_user@dest_host:dest_dir"
  exit -1
fi

source_dir=$1
dest=$2
dest_host=`echo $dest | cut -d: -f1`
dest_dir=`echo $dest | cut -d: -f2`

echo "Copying from '$source_dir' -> host='$dest_host', dir='$dest_dir'"
tar cf - $1 | ssh -A $dest_host "cd $dest_dir; tar xf -"
