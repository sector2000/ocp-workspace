#!/bin/bash -e

current_dir=$(dirname $(readlink -f $0))
source "${current_dir}/../variables"

yq_version=v4.43.1

echo "Installing tools..."

sudo -u ${shared_user} bash -c "
  set -e
  
  rm -rf \"${shared_dir}/\"{tools,bash_completion.tools}
  mkdir \"${shared_dir}/\"{tools,bash_completion.tools}
  chmod 775 \"${shared_dir}/\"{tools,bash_completion.tools}
  
  export http_proxy=${http_proxy}
  export https_proxy=${https_proxy}
  export no_proxy=${no_proxy}
  
  echo -n \"Installing yq...\"
  
  curl https://github.com/mikefarah/yq/releases/download/${yq_version}/yq_linux_amd64.tar.gz -L --fail --silent --show-error | tar xzOf - ./yq_linux_amd64 > \"${shared_dir}/tools/yq\"
  chmod 775 \"${shared_dir}/tools/yq\"
  \"${shared_dir}/tools/yq\" shell-completion bash > \"${shared_dir}/bash_completion.tools/yq\"
  chmod 664 \"${shared_dir}/bash_completion.tools/yq\"
  echo \" done\"
"

echo "Tools installed successfully"
