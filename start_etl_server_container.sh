#!/bin/bash
docker ps -q --filter "name=pentaho_etl" | grep -q . &&
docker stop pentaho_etl >/dev/null 2>&1 &&
docker rm pentaho_etl >/dev/null 2>&1
docker run -d -p 9080:9080 -e CARTE_PORT=9080 -e CARTE_HOSTNAME=localhost -e CARTE_USER=cluster -e CARTE_PASSWORD=cluster --name pentaho_etl --network dockernetwork --restart unless-stopped pentaho_etl:9.3.0