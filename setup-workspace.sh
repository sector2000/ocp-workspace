#!/bin/bash -e

current_dir=$(dirname $(readlink -f $0))
setup_dir="${current_dir}/setup"
source "${current_dir}/variables"

echo "Setting up workspace..."

"${setup_dir}/install-profiles.sh"
"${setup_dir}/install-configs.sh"
"${setup_dir}/install-python-packages.sh"
"${setup_dir}/install-scripts.sh"
"${setup_dir}/install-tools.sh"
"${setup_dir}/set-clusters.sh"

echo "Workspace set up successfully"
