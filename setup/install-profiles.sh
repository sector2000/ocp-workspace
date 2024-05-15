#!/bin/bash -e

current_dir=$(dirname $(readlink -f $0))
source "${current_dir}/../variables"

echo -n "Installing profiles..."

if [ -d "${current_dir}/profiles" ] && [ "$(ls -A ${current_dir}/profiles/)" ]; then
  temp_dir=$(mktemp -d)
  chmod 775 ${temp_dir}

  cp "${current_dir}/profiles/"* ${temp_dir}
  sed -i "s@##SHARED_DIR##@${shared_dir}@g" ${temp_dir}/*
  chmod 664 ${temp_dir}/*

  sudo -u ${shared_user} bash -c "
    set -e

    rm -rf \"${shared_dir}/profile.d\"
    mkdir \"${shared_dir}/profile.d\"
    chmod 775 \"${shared_dir}/profile.d\"

    cp ${temp_dir}/* \"${shared_dir}/profile.d\"
    chmod 664 \"${shared_dir}/profile.d/\"*
  "
  rm -rf ${temp_dir}
fi

echo " done"
