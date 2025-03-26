IMAGE_NAME="jupyter_container"
docker exec -it $(docker ps -aq --filter name=$IMAGE_NAME) /bin/bash 
