#!/bin/bash -e

current_dir=$(dirname $(readlink -f $0))
source "${current_dir}/../variables"

echo -n "Setting cluster definition file..."

temp_dir=$(mktemp -d)
chmod 775 ${temp_dir}
cp "${current_dir}/../clusters.yaml" ${temp_dir}
chmod 664 ${temp_dir}/*

sudo -u ${shared_user} bash -c "
  set -e
  
  rm -rf \"${shared_dir}/clusters\"
  mkdir \"${shared_dir}/clusters\"
  chmod 775 \"${shared_dir}/clusters\"

  cp ${temp_dir}/clusters.yaml \"${shared_dir}/clusters/clusters.yaml\"
  chmod 664 \"${shared_dir}/clusters/clusters.yaml\"
"

rm -rf ${temp_dir}

echo " done"
