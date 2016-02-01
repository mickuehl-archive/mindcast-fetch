# mindcast-fetch

mindcast.io podcast metadata fetch service

The service retrieves a podcast's rss feed and returns all relevant metadata on the podcast and its episodes as a single json document. Assuming that podcast rss feeds are not updated very frequently, the service caches responses for some time.

## Endpoints

The service only exposes two endpoints at the moment:

* GET /
* GET /info

Responses from the service conform to the basic ideas of the (JSON API specification)[http://jsonapi.org].

### GET /

#### Parameters

* f	RSS feed url, mandatory
* reload	true | false reload the rss feed if cached, development only, optional

Example

	curl http://localhost/?f=<podcast_feed_url>&reload=true

```json
{
	"links": {
		"self": "http://localhost/?f=<podcast_feed_url>"
	},
	"data": {
		"type": "podcast",
		"id": "1f115de222dc0d09067aa339a16e98bb",
		"attributes": {
			"title": "title",
			"subtitle": "subtitle (optional)",
			"summary": "summary (optional)",
			"description": "description (optional)",
			"image": "http://...jpg (optional)",
			"author": "author (optional)",
			"owner_name": "podcast owner (optional)",
			"owner_email": "podcast owner email (optional)",
			"language": "de-DE (optional)",
			"copyright" : "copyright (optional)"
			"generator": "generator app (optional)"
		},
		"links": {
			"self": "http://<podcast_feed_url>",
			"alternate": "http://<podcast_feed_url>/other_encoding",
			"next": "http://<podcast_feed_url>?paged=2",
			"first": "http://<podcast_feed_url>",
			"last": "http://<podcast_feed_url>?paged=xxx",
			"hub": "http://....",
			"payment": "https://flattr.com/subm...",
		},
		"included": {
			"type": "episode",
			"id": "afca730a17b393c6e4210d427db469fa",
			"attributes": {
				"guid": "podlove-2016-01-27t23:47:44+00:00-deaaf34c7b9847f (optional)",
				"title": "title",
				"subtitle": "subtitle (optional)",
				"author": "author (optional)",
				"summary": "summary (optional)",
				"duration": 12482, # (optional)
				"content_url": "http://...m4a",
				"content_length": 8030158,
				"content_type": "audio/mp4",
			},
			"links": {
				"payment": "https://flattr.com/submit/auto?...",
				"http://podlove.org/deep-link": "http://freakshow.fm/fs170-laden-laeuft#",
			},
			"included": {
				"type": "chapter",
				"id": "cda1e9514560f3fca5740bc939e3a73f",
				"attributes": {
					"start": "00:00:00.000",
					"title": "Intro",
				}
			}
			{
				"type": "chapter",
				"id": "5d404025079ca93278252bbdae527268",
				"attributes": {
					"start": "00:01:40.037",
					"title": "Begrüßung"
				}
			}
		}
	}
}

```

### GET /info

Returns the current version of the service.

#### Parameters

None

Example

	curl http://localhost/info

```json
{
	"links": {
		"self": "http://localhost:3000/info"
	},
	"data": {
		"type": "info",
		"id": 0,
		"attributes": {
			"version": "0.2.0"
		}
	}
}
```

## Deployment

### Build

	docker build -t mindcast/fetch .

This image is based on the generic Ruby / RAILS image `mindcast/ruby`

### Create

	docker create --name mindcast-fetch -p <private_ipv4>:<public_port>:9292 mindcast/fetch
