

Otros comandos

docker ps -a -q # listar el id de todos los contenedores

docker container rm $(docker ps -a -q) # eliminar todos los contenedores
