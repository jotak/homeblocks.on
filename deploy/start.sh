#!/bin/sh

docker run -i -p 80:8081 -v /homeblocks/secrets:/app/secrets -v /homeblocks/users:/app/users --name homeblocks --rm jotak/homeblocks

# Chances that the docker daemon needs to be restarted due to network not fully available on startup
if [ $? -ne 0 ]; then
	echo "Failure detected. Trying to restart docker."
	systemctl restart docker
	sleep 5
	docker run -i -p 80:8081 -v /home/homeblocks/secrets:/app/secrets -v /home/homeblocks/users:/app/users --name homeblocks --rm jotak/homeblocks
fi
