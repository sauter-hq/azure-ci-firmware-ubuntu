#!/bin/sh
INSTALL_PATH=$5

sudo chown sauter:sauter ${INSTALL_PATH} 

# Install Build Tools
sudo /bin/date +%H:%M:%S

echo "ooooo      VSTS AGENT + DOCKER SETUP      ooooo"

# Install Docker Engine and Compose
echo "Installing Docker CE"


sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install -y docker-ce
sudo service docker start
sudo usermod -aG docker $4


# Install VSTS build agent dependencies

echo "Installing libcurl4 and git-lfs package"
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt-get install -y libcurl4-openssl-dev git-lfs
sudo /bin/date +%H:%M:%S


# Download VSTS build agent and required security patch

echo "Downloading VSTS Build agent package"

cd ${INSTALL_PATH}
sudo -u $4 wget https://vstsagentpackage.azureedge.net/agent/2.144.0/vsts-agent-linux-x64-2.144.0.tar.gz 

sudo /bin/date +%H:%M:%S


echo "Installing VSTS Build agent package"

# Install VSTS agent
sudo -u $4 mkdir ${INSTALL_PATH}/vsts-agent
cd ${INSTALL_PATH}/vsts-agent
sudo -u $4 tar xzf ${INSTALL_PATH}/vsts-agent-linux*

echo "LANG=en_US.UTF-8" > .env
echo "export LANG=en_US.UTF-8" >> ${INSTALL_PATH}/.bashrc
export LANG=en_US.UTF-8

agent=`cat /etc/hostname`

echo URL: $1
echo PAT: HIDDEN
echo Pool: $3
echo Agent: $agent
echo User: $4
echo =============================== 

echo Running Agent.Listener
sudo -u $4 -E bin/Agent.Listener configure --unattended --nostart --replace --acceptteeeula --url $1 --auth PAT --token $2 --pool $3 --agent $agent 
echo ===============================
echo Running ./svc.sh install
sudo -E ./svc.sh install $4
echo ===============================
echo Running ./svc.sh start

sudo -E ./svc.sh start
echo ===============================

sudo chown -R $4.$4 .*

echo "ALL DONE!"
sudo /bin/date +%H:%M:%S
