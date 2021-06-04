FROM alpine:3.13

RUN apk --update add bash curl jq sed docker aws-cli \
	&& rm -rf /var/cache/apk/* \
	&& wget https://releases.hashicorp.com/terraform/0.15.5/terraform_0.15.5_linux_amd64.zip \
	&& unzip terraform_0.15.5_linux_amd64.zip \
	&& mv terraform /bin/ \
	&& rm terraform_0.15.5_linux_amd64.zip