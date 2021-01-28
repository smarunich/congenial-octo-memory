#!/usr/bin/env bash

container=$(buildah from fedora)
buildah config --env tf_version="0.14.5" $container
buildah config --env pk_version="1.6.6" $container
buildah config --env ansible_version="2.9.15" $container

buildah add $container octo-installer-ng /opt/octo/installer/
buildah add $container filesystem /

buildah run $container /bin/sh -c 'dnf -y install unzip'
buildah run $container /bin/sh -c 'dnf -y install python3-pip \
     python3-devel \
     openssl \
     python3-pyOpenSSL \
     curl \
     groff \
     jq \
     openssh \
     sshpass \
     vim \
     git \
     tmux \
     bash \
     supervisor; \
     pip3 install --ignore-installed --no-cache-dir --upgrade pip setuptools; \
     pip3 install --ignore-installed --no-cache-dir --upgrade -r /opt/octo/requirements.txt; \
     pip3 install --no-cache-dir --upgrade ansible==$ansible_version; \
     ln -s /usr/bin/python3 /usr/bin/python; \
     curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.0.30.zip" -o "/tmp/awscliv2.zip"; \
     unzip /tmp/awscliv2.zip; \
     /tmp/aws/install; \
     ansible-galaxy collection install amazon.aws; \
     curl -s -o /tmp/packer.zip.zip https://releases.hashicorp.com/packer/${pk_version}/packer_$pk_version_linux_amd64.zip; \
     unzip -d /usr/local/bin /tmp/packer.zip; \
     rm -rf /tmp/packer.zip; \
     curl -s -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${tf_version}/terraform_$tf_version_linux_amd64.zip; \
     unzip -d /usr/local/bin /tmp/terraform.zip; \
     rm -rf /tmp/terraform.zip; \
     curl -s -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl; \
     chmod +x /usr/local/bin/kubectl; \
     curl -k https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash; \
     rm -rf /tmp/*; \
     dnf clean all' 

buildah config --workingdir /opt/octo/terraform $container
buildah run $container terraform init

buildah config --workingdir /opt/octo
buildah config --entrypoint '[ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]' $container

buildah commit $container octo-orchestrator:buildah
