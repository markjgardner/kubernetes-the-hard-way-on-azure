# You can pick any Debian/Ubuntu-based image. 😊
FROM mcr.microsoft.com/vscode/devcontainers/base:0-buster

COPY library-scripts/*.sh /tmp/library-scripts/

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \ 
    && apt-get install -y graphviz \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# [Option] Install Azure CLI
ARG INSTALL_AZURE_CLI="true"
# [Option] Install Docker CLI
ARG INSTALL_DOCKER="true"
# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="none"
ENV NVM_DIR=/usr/local/share/nvm
ENV NVM_SYMLINK_CURRENT=true \
    PATH=${NVM_DIR}/current/bin:${PATH}
RUN if [ "${INSTALL_AZURE_CLI}" = "true" ]; then bash /tmp/library-scripts/azcli-debian.sh; fi \
    && if [ "${NODE_VERSION}" != "none" ]; then bash /tmp/library-scripts/node-debian.sh "${NVM_DIR}" "${NODE_VERSION}" "${USERNAME}"; fi \
    && if [ "${INSTALL_DOCKER}" = "true" ]; then \
        bash /tmp/library-scripts/docker-debian.sh "true" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}"; \
    else \
        echo '#!/bin/bash\n"$@"' > /usr/local/share/docker-init.sh && chmod +x /usr/local/share/docker-init.sh; \
    fi \
    && rm -rf /var/lib/apt/lists/*

# Install Terraform, tflint, Terragrunt
ARG TERRAFORM_VERSION=0.12.16
ARG TFLINT_VERSION=0.8.2
ARG TERRAGRUNT_VERSION=0.28.1
RUN bash /tmp/library-scripts/terraform-debian.sh "${TERRAFORM_VERSION}" "${TFLINT_VERSION}" "${TERRAGRUNT_VERSION}" \
    && rm -rf /tmp/library-scripts

# Install cfssl & cfssljson
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get install -y gcc-8 && ln -s /usr/bin/gcc-8 /usr/bin/gcc
RUN wget -q --https-only https://golang.org/dl/go1.17.1.linux-amd64.tar.gz -O golang.tar.gz \
    && tar -C /usr/local -xzf golang.tar.gz \
    && rm -rf golang.tar.gz
ENV PATH /usr/local/go/bin:/home/${USERNAME}/go/bin:$PATH
RUN export GOBIN="/home/vscode/go/bin" \
    && go install github.com/cloudflare/cfssl/cmd/cfssl@latest \
    && go install github.com/cloudflare/cfssl/cmd/cfssljson@latest

# Install kubectl
RUN sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get install -y kubectl

ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>