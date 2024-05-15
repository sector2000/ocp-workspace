#!/bin/bash -e

current_dir=$(dirname $(readlink -f $0))
source "${current_dir}/../variables"

echo "Installing scripts..."

if [ -d "${current_dir}/scripts/" ] && [ "$(ls -A ${current_dir}/scripts/)" ]; then
  temp_dir=$(mktemp -d)
  chmod 775 ${temp_dir}
  
  cp "${current_dir}/scripts/"* ${temp_dir}
  sed -i "s@##SHARED_DIR##@${shared_dir}@g" ${temp_dir}/*
  sed -i "s@##IMAGE##@${container_image}@g" ${temp_dir}/*
  sed -i "s@##IMAGE_TAG##@${container_image_tag}@g" ${temp_dir}/*
  chmod 664 ${temp_dir}/*
  
  python_version=$(python -c 'import sys; version=sys.version_info[:3]; print("{0}.{1}".format(*version))')
  
  sudo -u ${shared_user} bash -c "
    set -e
    
    rm -rf \"${shared_dir}/\"{scripts,bash_completion.scripts}
    mkdir \"${shared_dir}/\"{scripts,bash_completion.scripts}
    chmod 775 \"${shared_dir}/\"{scripts,bash_completion.scripts}
    
    cp ${temp_dir}/* \"${shared_dir}/scripts\"
    chmod 775 \"${shared_dir}/scripts/\"*
    
    export PYTHONPATH=\"${shared_dir}/lib/python${python_version}/site-packages:${shared_dir}/lib64/python${python_version}/site-packages\"
    \"${shared_dir}/bin/activate-global-python-argcomplete\" --dest \"${shared_dir}/bash_completion.scripts\"
    chmod 664 \"${shared_dir}/bash_completion.scripts/\"*
  "
  rm -rf ${temp_dir}  
fi

echo "Scripts installed successfully"
