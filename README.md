# mindcast-fetch

mindcast.io podcast metadata fetch service

The service retrieves a podcast's rss feed and returns all relevant metadata on the podcast and its episodes as a single json document. Assuming that podcast rss feeds are not updated very frequently, the service caches responses for some time.

## Endpoints

The service only exposes two endpoints at the moment:

* GET /
* GET /info

Responses from the service conform to the basic ideas of the (JSON API specification)[http://jsonapi.org].

### GET /

Example

	curl http://localhost/?f=<podcast_feed_url>

```json
{
	"links": {
		"self": "http://localhost:3000/?f=http://freakshow.fm/feed/m4a"
	}
	"data": {
		"type": "podcast",
		"id": "1f115de222dc0d09067aa339a16e98bb",
		"attributes": {
			"title": "Freak Show",
			"subtitle": "Menschen! Technik! Sensationen!",
			"summary": "Die muntere Talk Show ...",
			"description": "Menschen! Technik! Sensationen!",
			"image": "http://freakshow.fm/wp-co...94270edf037e877/freak-show_original.jpg",
			"author": "Metaebene Personal Media - Tim Pritlove",
			"owner_name": "Tim Pritlove",
			"owner_email": "freakshow@metaebene.me",
			"language": "de-DE",
			"generator": "Podlove Podcast Publisher v2.3.8"
		},
		"links": {
			"self": "http://feeds.metaebene.me/freakshow/m4a",
			"alternate": "http://freakshow.fm/feed/opus",
			"next": "http://freakshow.fm/feed/m4a?paged=2",
			"first": "http://freakshow.fm/feed/m4a",
			"last": "http://freakshow.fm/feed/m4a?paged=6",
			"hub": "http://metaebene.superfeedr.com",
			"payment": "https://flattr.com/subm...",
		},
		"included": {
			"type": "episode",
			"id": "afca730a17b393c6e4210d427db469fa",
			"attributes": {
				"guid": "podlove-2016-01-27t23:47:44+00:00-deaaf34c7b9847f",
				"title": "FS170 Laden läuft",
				"subtitle": "Bitcoin — Wikipedia-Relevanz — ...",
				"author": "Metaebene Personal Media - Tim Pritlove",
				"summary": "Eine Sendung in kleine...",
				"duration": 12482,
				"content_url": "http://tracking.feedpress.it/link/13453/2442894/fs170-laden-laeuft.m4a",
				"content_length": 80153098,
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

docker create --name fetch -p <private_ipv4>:<public_port>:9292 mindcast/fetch
