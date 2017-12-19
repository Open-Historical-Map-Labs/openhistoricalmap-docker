sudo docker rmi $(sudo docker images -aq) -f && sudo docker rm $(sudo docker ps -aq) -f
sudo rm -rf ./postgres/data && mkdir -p ./postgres/data
