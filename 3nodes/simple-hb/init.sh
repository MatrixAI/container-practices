###
### Instantiate 3 docker containers wth Simple-hb running
###

cleanup() {
  docker stop peer1 peer2 peer3
  docker rm peer1 peer2 peer3
  docker network rm simple-hb-br 2> /dev/null
}

if [ ! -f "./Dockerfile" ]
then
  cat << EOF > Dockerfile
# Pull base image.
FROM python:3

ADD . /home/vagrant/

WORKDIR /home/vagrant/

CMD ./main.py

# Expose ports.
EXPOSE 8080
EOF
fi

echo Dockerfile written

cleanup

docker build -t simple-hb .

echo Docker image built

docker network create \
  -d bridge \
  --subnet=10.0.4.0/24 \
  simple-hb-br

echo Network simple-hb-br created

sudo docker run -d --name peer1 \
  --network simple-hb-br \
  --ip "10.0.4.21" \
  --publish 8080:8080 \
  simple-hb > /dev/null

echo peer1 running

sudo docker run -d --name peer2 \
  --network simple-hb-br \
  --ip "10.0.4.22" \
  --publish 8081:8080 \
  simple-hb > /dev/null

echo peer2 running

sudo docker run -d --name peer3 \
  --network simple-hb-br \
  --ip "10.0.4.23" \
  --publish 8082:8080 \
  simple-hb > /dev/null

echo peer3 running
