#!/bin/bash -e

current_dir=$(dirname $(readlink -f $0))
setup_dir="${current_dir}/setup"
source "${current_dir}/variables"

if [ $(id -u) -ne 0 ]; then
  echo "This script must be run as root!"
  exit 1
fi

if ! id -u ${shared_user} >/dev/null 2>&1; then
  echo "User ${shared_user} does not exist! Create the user ${shared_user} and try again."
  exit 1
fi

echo -n "Setting up host..."

shared_group=$(id -gn ${shared_user})

temp_dir=$(mktemp -d)
chmod 775 ${temp_dir}

cat << 'EOF' >${temp_dir}/load_${shared_group}_group_profiles.sh
if id -nGz | grep -qzxF "##SHARED_GROUP##"; then
  shopt -s nullglob
  for file in "##SHARED_DIR##/profile.d/"*; do
    . "${file}"
  done
  shopt -u nullglob
fi
EOF
sed -i "s@##SHARED_GROUP##@${shared_group}@g" ${temp_dir}/load_${shared_group}_group_profiles.sh
sed -i "s@##SHARED_DIR##@${shared_dir}@g" ${temp_dir}/load_${shared_group}_group_profiles.sh
chmod 664 ${temp_dir}/load_${shared_group}_group_profiles.sh

sudo bash -c "
  set -e
  
  mkdir -p \"${shared_dir}\"
  chown ${shared_user}:${shared_group} \"${shared_dir}\"
  chmod 775 \"${shared_dir}\"

  cp ${temp_dir}/load_${shared_group}_group_profiles.sh /etc/profile.d/load_${shared_group}_group_profiles.sh
  chown root:root /etc/profile.d/load_${shared_group}_group_profiles.sh
  chmod 644 /etc/profile.d/load_${shared_group}_group_profiles.sh
"

rm -rf ${temp_dir}

echo " done"
