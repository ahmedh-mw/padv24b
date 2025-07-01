# 1. Preparing your Software Image
## 1.1 Build PADV non-interactive docker image
Following MathWorks Reference Architectures, you need to build an image from non-interactive docker file. you can find more details at the following repo:
https://github.com/mathworks-ref-arch/matlab-dockerfile

Example file path: https://raw.githubusercontent.com/mathworks-ref-arch/matlab-dockerfile/refs/heads/main/alternates/non-interactive/Dockerfile

```
# PowerShell script
$CONTAINER_REGISTRY = "<Container_Register_Domain>"
$PADV_IMAGE = "<Custom_Docker_Image_Name>"
$PADV_IMAGE_TAG = "<Custom_Image_Tag>"
$MATLAB_RELEASE = "R2024b"
$PADV_IMAGE_NAME = "${PADV_IMAGE}:${PADV_IMAGE_TAG}"

docker buildx build -f non-interactive.Dockerfile `
  --build-arg MATLAB_RELEASE=$MATLAB_RELEASE `
  --build-arg MATLAB_PRODUCT_LIST='MATLAB Simulink Simulink_Check Simulink_Design_Verifier Simulink_Report_Generator Simulink_Coder Simulink_Compiler Simulink_Test Embedded_Coder Simulink_Coverage Requirements_Toolbox CI/CD_Automation_for_Simulink_Check' `
  -t $CONTAINER_REGISTRY/$PADV_IMAGE_NAME .
  ```
> **_NOTE:_** You can remove or add more MATLAB's toolboxes by updating the 'MATLAB_PRODUCT_LIST' argument

> **_NOTE:_** Default docker file has ENTRYPOINT value equal to "xvfb-run" which may not be suitable for generic purpose senatios

## 1.2 Build PADV CI docker image
This image add a top layer to the non-interactive image by adding the following libraries and CLIs python3, git client, JFrog cli, Azure cli, AWS cli. This layer also clear the default docker image ENTRYPOINT value for better flexibility.

You can use 'ci-addons.Dockerfile' to build this image using the following script
```
# PowerShell script
$CONTAINER_REGISTRY = "<Container_Register_Domain>"
$PADV_IMAGE = "<Custom_Docker_Image_Name>"
$PADV_IMAGE_TAG = "<Custom_Image_Tag>"
$MATLAB_RELEASE = "R2024b"
$PADV_IMAGE_NAME = "${PADV_IMAGE}:${PADV_IMAGE_TAG}"

$CI_TAG = "ci"
$PADV_CI_IMAGE_NAME = "${PADV_IMAGE_NAME}_${CI_TAG}"

docker build -f ci-addons.Dockerfile `
    --build-arg BASE_IMAGE="$CONTAINER_REGISTRY/$PADV_IMAGE_NAME" `
    -t $CONTAINER_REGISTRY/$PADV_CI_IMAGE_NAME .
```
# 2. Configure your github runner
GitHub actions doens't support container operations on Windows runners, they are only supported on Linux runners. You can use WSL environemnt as your GitHub actions runner and you need also to install your docker-ce engine to support container operations.

```
########### Intsalling WSL
wsl --install -d Ubuntu
wsl --set-default Ubuntu

########### Installing Dokcer engine
# Add Docker's official GPG key for ubuntu:
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install docker engine
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
 
# Adjusting the access
sudo chown $USER /var/run/docker.sock
sudo usermod -aG docker $USER
newgrp docker

# Optional: Install portainer
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/home/ahmedh/data portainer/portainer-ce:latest
```

Add new self-hosted runner using the project settings screen at Runners section.
```
mkdir ~/runners/gh/gh01
cd ~/runners/gh/gh01
curl -o actions-runner-linux-x64-2.325.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.325.0/actions-runner-linux-x64-2.325.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.325.0.tar.gz
rm actions-runner-linux-x64-2.325.0.tar.gz
./config.sh --url https://github.com/<org>/<project> --token <token>
./run.sh

docker login slcicd.azurecr.io -u slcicd -p "<DOCKER_REGISTRY_CREDENTIALS>"
docker image pull <FULL_Image>
###########################

To use the Docker executor with existing runner, you must manually define Docker as the executor in config.toml and for new runner you must use gitlab-runner register --executor "docker" command to automatically define it.
> **_NOTE:_** Make sure to review the configuration for allowed_images, allowed_pull_policies and pull_policy configuration keys.

> **_NOTE:_** If you are using a MATLAB Docker image based on a Linux OS, you must configure your GitLab runner either on a Linux machine with Docker Engine installed or on a Windows machine with Docker Engine running in Linux mode. Using WSL is also an option as it is equvilant to using a Linux machine.

# 3. Configure your gitlab pipeline

In CI environemnts, MATLAB batch licensing token is the recommended way to license your MATLAB containers. MATLAB batch licensing token tool is already installed inside your Docker image but you need to supply the license token secrets through the container environemnt variables. We recommend saving the token secrets into your GitLab CI/CD variables section as 'MLM_LICENSE_TOKEN_SECRET' variable with visibality equal to "Masked and hidden"

The example .gitlab-ci.yml pipeline will send this token secret to the different containers automatically.

You need to set IMAGE_TAG variable at .gitlab-ci.yml variables section. This image will be used for all the pipeline jobs.

> **_NOTE:_** IMAGE_TAG variable is ignored if gitlab runner is not configured to use Docker executor.

At "generate_gitlab_pipeline.m", uncomment Docker image settings section and configure a valid MatlabLaunchCmd, MatlabStartupOptions and AddBatchStartupOption values.