FROM alpine:3.12.3

ARG tf_version="0.14.5"
ARG pk_version="1.6.6"
ARG ansible_version="2.9.15"
ENV glibc_version="2.31-r0"

ADD filesystem /
ADD installer /opt/octo/installer/

# Install tools
RUN apk add --no-cache \
    python3 \
    py3-pip \
    python3-dev \
    openssl \
    py3-openssl \
    curl \
    groff \
    jq \
    openssh \
    sshpass \
    vim \
    git \
    tmux \
    bash \
    supervisor \
    && apk add --no-cache --virtual .build-deps gcc musl-dev openssl-dev libffi-dev \
    && pip3 install --ignore-installed --no-cache-dir --upgrade pip setuptools \
    && pip3 install --ignore-installed --no-cache-dir --upgrade -r /opt/octo/requirements.txt \
    && pip3 install --no-cache-dir --upgrade ansible==${ansible_version} \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && ansible-galaxy collection install amazon.aws \
    && curl -s -o /tmp/packer.zip.zip https://releases.hashicorp.com/packer/${pk_version}/packer_${pk_version}_linux_amd64.zip \
    && unzip -d /usr/local/bin /tmp/packer.zip \
    && rm -rf /tmp/packer.zip \
    && curl -s -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_amd64.zip \
    && unzip -d /usr/local/bin /tmp/terraform.zip \
    && rm -rf /tmp/terraform.zip \
    && curl -s -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && curl -k https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

# Copied from https://stackoverflow.com/a/61268529/3895853
# install glibc compatibility for alpine and AWS CLI v2
RUN apk --no-cache add \
        binutils \
        curl \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${glibc_version}/glibc-${glibc_version}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${glibc_version}/glibc-bin-${glibc_version}.apk \
    && apk add --no-cache \
        glibc-${glibc_version}.apk \
        glibc-bin-${glibc_version}.apk \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && aws/install \
    && rm -rf \
        awscliv2.zip \
        aws \
        /usr/local/aws-cli/v2/*/dist/aws_completer \
        /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
        /usr/local/aws-cli/v2/*/dist/awscli/examples \
    && apk --no-cache del \
        binutils \
        curl \
    && rm glibc-${glibc_version}.apk \
    && rm glibc-bin-${glibc_version}.apk \
    && rm -rf /var/cache/apk/*

WORKDIR /opt/octo/terraform
RUN terraform init

# Clean up
WORKDIR /opt/octo
EXPOSE 8000
ENTRYPOINT [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
