#!/bin/bash
#================================================================================
#title           : nyu-appsec-a3-ubuntu20043lts-setup.sh
#description     : This script will install the software necessary to complete
#		    Assignment 3 as well as clone the assignment files.
#author		: John Ryan Allen (jra457@nyu.edu)
#date            : October 19, 2021
#version         : 0.1
#usage		 : sudo bash nyu-appsec-a3-ubuntu20043lts-setup.sh
#notes           : Run as standard user, ***NOT ROOT***. Provide sudo password
#		    when prompted. Tested on fresh install of Ubuntu 20.04.3 LTS.
#		    Must run this script twice to complete the installation.
#bash_version    : 5.0.17(1)-release (x86_64-pc-linux-gnu)
#================================================================================

# Created this var just in case script ever decides to get fancier.
# For now, this pretty much only defines where the assignment repo will be cloned.
installDir="$HOME/Desktop"

cd $installDir

# Install docker if user is not already in docker group
if [[ $(id) != *\(docker\)* ]]; then
	# INSTALL DOCKER
	echo '##################################################'
	echo '[*] Installing Docker...'
	echo '##################################################'
	sleep 3
	sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io

	# CONFIGURE STANDARD USER TO MANAGE DOCKER WITHOUT ROOT
	echo '##################################################'
	echo '[*] Configuring Docker...'
	echo '##################################################'
	sleep 3
	sudo usermod -aG docker $USER

	echo '#####################################################################'
	echo '[*] Almost there! Reboot and run this script one more time to finish.'
	echo '#####################################################################'

else

	# INSTALL KUBERNETES CLI TOOLS
	echo '##################################################'
	echo '[*] Installing kubectl...'
	echo '##################################################'
	sleep 3
	sudo apt-get install -y apt-transport-https ca-certificates curl
	sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
	echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
	sudo apt-get update
	sudo apt-get install -y kubectl


	echo '##################################################'
	echo '[*] Installing minikube...'
	echo '##################################################'
	curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
	sudo install minikube-linux-amd64 /usr/local/bin/minikube
	rm minikube-linux-amd64

	# START MINIKUBE
	echo '##################################################'
	echo '[*] Installing kubectl...'
	echo '##################################################'
	sleep 3
	minikube start
	eval $(minikube docker-env)


	# CLONE REPOSITORY
	echo '##################################################'
	echo "[*] Cloning assignment repository to {$installDir}..."
	echo '##################################################'
	sleep 3
	git clone https://github.com/kcg295/AppSecAssignment3.1.git; cd AppSecAssignment3.1

	# SET UP CLUSTERS
	echo '##################################################'
	echo '[*] Building Dockerfiles for Kubernetes cluster...'
	echo '##################################################'
	sleep 3
	docker build -t nyuappsec/assign3:v0 .
	docker build -t nyuappsec/assign3-proxy:v0 proxy/
	docker build -t nyuappsec/assign3-db:v0 db/

	# CREATE PODS AND SERVICES
	echo '##################################################'
	echo '[*] Creating Kubernetes pods and services...'
	echo '##################################################'
	sleep 3
	kubectl apply -f db/k8
	kubectl apply -f GiftcardSite/k8
	kubectl apply -f proxy/k8


	# VERIFY PODS AND SERVICES
	echo '###################################################################################'
	echo '[*] Checking on status of pods and services...'
	echo '###################################################################################'
	echo '[*] Waiting 60 seconds for pods to transition from "Pending" to "Running" status...'
	echo '###################################################################################'
	sleep 30
	kubectl get pods
	kubectl get service

	echo '####################################################################'
	echo '[*] All done! You are ready to begin working on AppSec Assignment 3.'
	echo '####################################################################'

fi