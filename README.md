# Red Hat OpenShift Workspace

Red Hat Openshift Workkspace (ocp-workspace) is a container image that can be used to manage Red Hat OpenShift Container Platforms.

It is intended to be run as rootless podman container and to be shared by multiple users.

## Requirements

The host where the ocp-workspace container will be run must fulfil the following requirements:

* podman
* a shared user whose group is also a supplementary group of the users that need to run the ocp-workspace
* the users that need to run the ocp-workspace must be albe to switch to the shared user
* python 3

## Installation

Modify the `./variables` according to your needs.

Modify the `./cluster.yaml` with the details (name and base domain) of your Openshift clusters:

```
cluster1:
  base_domain: ocp.example.com

cluster2:
  base_domain: ocp.example.com
```

Then run:

```
sudo ./setup-host.sh
```
To setup the host.

NOTE: this script must be executed as root because it creates the shared directory, give it the correct permissions and 
adds to the /etc/profile.d directory a profile that luads, for users who belong to the group of the shared user, all the
profiles that will be created in the <shared dir>/profile.d directory.


Then run:

```
./setup-workspace.sh
```
To setup the ocp-workspace.

NOTE: this command must be executed by the shared user or by a user who can switch to the shared user.

To update the cluster list, modify the `./clusters.yaml` file and run `./setup-workspace.sh` again.


## Usage

After setup type: `ocp-workspace --help` to see the options.

**NOTE:** bash completion is available

The directory `~/workspace` will be mounted (rw) within your container in `~/workspace`.

Files and directories placed in `~/.ocp-workspace/<cluster-name>/home` will be mounted (rw) within the container in `~/`.

## Workspace

The workspace image contains, among other variuos tools, the following tools to help you work on OpenShift clusters:

* `kubeseal` - SealedSecrets binary
* `helm` - To test out your helm charts
* `oc`/ `kubectl` - **The** tools
* `oc-mirror` - Helping you to mirror OpenShift Content
* `openshift-install`- To manually install clusters


to prepare the management / bastion host with required packages, tools, scripts and configurations


## Build Image

Run:

```
podman build . -t ocp-workspace
```

to build the ocp-workspace container image.
