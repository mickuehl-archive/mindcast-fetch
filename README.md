# mindcast-fetch

mindcast.io podcast metadata fetch service

The service retrieves a podcast's rss feed and returns all relevant metadata on the podcast and its episodes as a single json document. Assuming that podcast rss feeds are not updated very frequently, the service caches responses for some time.

## Endpoints

The service only exposes two endpoints at the moment:

* GET /
* GET /info

### GET /

### GET /info

Returns the current version of the service.


## Deployment

### Build

	docker build -t mindcast/fetch .

This image is based on the generic Ruby / RAILS image `mindcast/ruby`

### Create

docker create --name fetch -p <private_ipv4>:<public_port>:9292 mindcast/fetch
