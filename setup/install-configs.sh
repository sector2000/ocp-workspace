#!/bin/bash -e

current_dir=$(dirname $(readlink -f $0))
source "${current_dir}/../variables"

echo -n "Installing configs..."

if [ -d "${current_dir}/configs/" ] && [ "$(ls -A ${current_dir}/configs/)" ]; then
  temp_dir=$(mktemp -d)
  chmod 775 ${temp_dir}
  
  cp "${current_dir}/configs/"* ${temp_dir}
  sed -i "s@##SHARED_DIR##@${shared_dir}@g" ${temp_dir}/*
  chmod 664 ${temp_dir}/*
  
  sudo -u ${shared_user} bash -c "
    set -e
    
    rm -rf \"${shared_dir}/config\"
    mkdir \"${shared_dir}/config\"
    chmod 775 \"${shared_dir}/config\"
    
    cp ${temp_dir}/* \"${shared_dir}/config\"
    chmod 664 \"${shared_dir}/config/\"*
  "
  rm -rf ${temp_dir}
fi
  
echo " done"
