# mindcast-fetch

mindcast.io podcast metadata fetch service


## Build

	docker build -t mindcast/fetch .

## Create

docker create --name fetch -e REPO="https://github.com/mindcastio/mindcast-fetch.git" -p <private_ipv4>:20010:9292 mindcast/fetch