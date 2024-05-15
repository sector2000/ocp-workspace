#!/bin/bash -e

current_dir=$(dirname $(readlink -f $0))
source "${current_dir}/../variables"

pip_version=23.3.2
argparse_version==1.4.0
argcomplete_version=3.3.0
tabulate_version=0.9.0

echo "Installing Python packages..."

sudo -u ${shared_user} bash -c "
  set -e
  
  rm -rf \"${shared_dir}/\"{bin,lib,lib64}
  mkdir \"${shared_dir}/\"{bin,lib,lib64}

  export http_proxy=${http_proxy}
  export https_proxy=${https_proxy}
  export no_proxy=${no_proxy}
  
  python -m pip install --upgrade --prefix \"${shared_dir}\" --no-warn-script-location \
      pip==${pip_version}
  
  \"${shared_dir}/bin/pip3\" install --upgrade --prefix \"${shared_dir}\" --no-warn-script-location \
      argparse==${argparse_version} \
      argcomplete==${argcomplete_version} \
      tabulate==${tabulate_version}
  

  chmod -R g+w \"${shared_dir}/bin\" \"${shared_dir}/lib\" \"${shared_dir}/lib64\"
"

echo "Python packages successfully installed"
