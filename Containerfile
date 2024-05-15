FROM fedora:latest

ARG OPENSHIFT_VERSION="4.14.18"
ARG HELM_VERSION="3.14.4"
ARG HELM_SECRETS_VERSION="4.6.0"
ARG SEALED_SECRETS_VERSION="0.26.2"
ARG YQ_VERSION="4.43.1"
ARG ARGPARSE_VERSION="1.4.0"
ARG ARGCOMPLETE_VERSION="3.3.0"

ENV USER="user"

ENV HELM_PLUGINS="/etc/helm/plugins"

COPY build-assets/startup.sh /usr/local/bin/startup.sh
ADD --chmod=0755 build-assets/sops.tar.gz /usr/local/bin/
 # This is a version of sops compiled from source (commit 6b91c4e4c7c090d4770324f1d50b18b6cfbc1a48). It includes the --mac-only-encrypted option

RUN dnf -y update && \
    dnf -y install \
        git-core \
        jq \
        openssl \
        bash-completion \
        httpd-tools \
        python3-pip \
        tmux \
        ncurses \
        which \
        gpgme  && \
    dnf clean all && \
    rm -rf /var/lib/cache/dnf /var/log/*

RUN pip3 install --upgrade --no-cache-dir \
        argparse==${ARGPARSE_VERSION} \
        argcomplete==${ARGCOMPLETE_VERSION}

RUN useradd $USER && \
    chown -R ${USER} /home/${USER} && \
    mkdir -p /home/${USER}/workspace

RUN cd $(mktemp -d) && \
    curl https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OPENSHIFT_VERSION}/openshift-client-linux.tar.gz | tar xzvf - && \
    curl https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OPENSHIFT_VERSION}/openshift-install-linux.tar.gz | tar xzvf - && \
    curl https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OPENSHIFT_VERSION}/oc-mirror.tar.gz | tar xzvf - && \
    curl https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar xzvf - && \
    curl -L https://github.com/bitnami-labs/sealed-secrets/releases/download/v${SEALED_SECRETS_VERSION}/kubeseal-${SEALED_SECRETS_VERSION}-linux-amd64.tar.gz | tar xzvf - && \
    curl -L https://mirror.openshift.com/pub/openshift-v4/clients/butane/latest/butane -o ./butane && \
    curl -L https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 -o ./yq && \
    mv oc* kube* linux-amd64/helm butane yq /usr/local/bin && \
    chown root:root /usr/local/bin/* && \
    chmod +rx /usr/local/bin/* && \
    rm -rf /tmp/*

RUN kubectl completion bash > /etc/bash_completion.d/kubectl && \
    helm completion bash > /etc/bash_completion.d/helm && \
    oc completion bash > /etc/bash_completion.d/oc && \
    oc mirror completion bash |grep -v '\.oc-mirror.log' > /etc/bash_completion.d/oc-mirror && \
    yq shell-completion bash > /etc/bash_completion.d/yq && \
    activate-global-python-argcomplete

RUN helm plugin install https://github.com/jkroepke/helm-secrets --version v${HELM_SECRETS_VERSION}


VOLUME /home/user/.ssh
VOLUME /home/user/workspace

WORKDIR /home/user/workspace

USER root

ENTRYPOINT /usr/bin/bash
