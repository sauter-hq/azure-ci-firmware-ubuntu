#!/bin/sh

sudo chown sauter:sauter /mnt/

# Install Build Tools
sudo /bin/date +%H:%M:%S > /mnt/install.progress.txt

echo "ooooo      VSTS AGENT + DOCKER SETUP      ooooo" >> /mnt/install.progress.txt

# Install Docker Engine and Compose
echo "Installing Docker CE" >> /mnt/install.progress.txt


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
sudo usermod -aG docker $5


# Install VSTS build agent dependencies

echo "Installing libcurl4 and git-lfs package" >> /mnt/install.progress.txt
sudo apt-get install -y libcurl4-openssl-dev 
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
#sudo apt-get -y install libunwind8 libcurl3
sudo /bin/date +%H:%M:%S >> /mnt/install.progress.txt


# Download VSTS build agent and required security patch

echo "Downloading VSTS Build agent package" >> /mnt/install.progress.txt

cd /mnt/
sudo -u $5 wget https://vstsagentpackage.azureedge.net/agent/2.144.0/vsts-agent-linux-x64-2.144.0.tar.gz 

sudo /bin/date +%H:%M:%S >> /mnt/install.progress.txt


echo "Installing VSTS Build agent package" >> /mnt/install.progress.txt

# Install VSTS agent
sudo -u $5 mkdir /mnt/vsts-agent
cd /mnt/vsts-agent
sudo -u $5 tar xzf /mnt/downloads/vsts-agent-linux*

echo "LANG=en_US.UTF-8" > .env
echo "export LANG=en_US.UTF-8" >> /mnt/.bashrc
export LANG=en_US.UTF-8

echo URL: $1 > /mnt/vsts.install.log.txt 2>&1
echo PAT: HIDDEN >> /mnt/vsts.install.log.txt 2>&1
echo Pool: $3 >> /mnt/vsts.install.log.txt 2>&1
echo Agent: $4 >> /mnt/vsts.install.log.txt 2>&1
echo User: $5 >> /mnt/vsts.install.log.txt 2>&1
echo =============================== >> /mnt/vsts.install.log.txt 2>&1

echo Running Agent.Listener >> /mnt/vsts.install.log.txt 2>&1
sudo -u $5 -E bin/Agent.Listener configure --unattended --nostart --replace --acceptteeeula --url $1 --auth PAT --token $2 --pool $3 --agent $4 >> /mnt/vsts.install.log.txt 2>&1
echo =============================== >> /mnt/vsts.install.log.txt 2>&1
echo Running ./svc.sh install >> /mnt/vsts.install.log.txt 2>&1
sudo -E ./svc.sh install $5 >> /mnt/vsts.install.log.txt 2>&1
echo =============================== >> /mnt/vsts.install.log.txt 2>&1
echo Running ./svc.sh start >> /mnt/vsts.install.log.txt 2>&1

sudo -E ./svc.sh start >> /mnt/vsts.install.log.txt 2>&1
echo =============================== >> /mnt/vsts.install.log.txt 2>&1

sudo chown -R $5.$5 .*

echo "ALL DONE!" >> /mnt/install.progress.txt
sudo /bin/date +%H:%M:%S >> /mnt/install.progress.txt
