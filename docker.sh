sudo apt-get install apt-transport-https ca-certificates curl gnupg2  software-properties-common  -y
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
	   "deb [arch=amd64] https://download.docker.com/linux/debian \
	      $(lsb_release -cs) \
	         stable"

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose -y --allow-unauthenticated
