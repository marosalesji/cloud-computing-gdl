
### neo4 

```
docker run -d --name neo4j -p 7474:7474 -p 7687:7687 -e NEO4J_AUTH=neo4j/password123 neo4j

docker exec -it neo4j cypher-shell -u neo4j -p password123

###
docker exec -it app3-db-1 psql -U postgres -d tareas
SELECT * FROM TAREAS;


```
