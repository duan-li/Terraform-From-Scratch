FROM alpine:3.13

RUN apk --update add bash curl jq sed docker aws-cli \
	&& rm -rf /var/cache/apk/* \
	&& wget https://releases.hashicorp.com/terraform/0.15.5/terraform_0.15.5_linux_amd64.zip \
	&& unzip terraform_0.15.5_linux_amd64.zip \
	&& mv terraform /bin/ \
	&& rm terraform_0.15.5_linux_amd64.zip \
	&& curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_arm64.tar.gz" | tar xz -C /tmp \
	&& mv /tmp/eksctl /usr/local/bin \
	&& curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
	&& mv kubectl /usr/local/bin \
	&& chmod +x /usr/local/bin/kubectl


