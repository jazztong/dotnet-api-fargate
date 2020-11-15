FROM amazon/aws-cli

RUN amazon-linux-extras install docker -y
RUN yum install make unzip jq -y
# We need terraform to test ours terraform script
RUN curl -O https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip
RUN unzip terraform_0.13.5_linux_amd64.zip -d /usr/bin/
RUN terraform -v
# We need dotnet sdk to test dotnet application
RUN rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
RUN yum install dotnet-sdk-3.1 -y