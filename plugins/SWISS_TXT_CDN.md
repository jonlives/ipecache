SWISS TXT CDN
=============
Purges URLS from the [SWISS TXT CDN](http://www.swisstxt.ch/).

Hooks
-----
- `cdn_purge`

Configuration
-------------
```yaml
plugins:
  swisstxt_cdn:
    api_key: sample_key_e8e55aff-61e3-4588-ab98-4d3ea58be7c8
    api_secret: xyz5678xyz5678xyz5678xyz5678xyz5678xyz5678xyz5678
```

#### api_key
This is the api_key of the SWISS TXT CDN account you want to use

- Type: `String`

#### api_secret
This is the api_secret of the SWISS TXT CDN account you want to use

- Type: `String`

#### url (optional)
The URL of the SWISS TXT CDN API. This parameter defaults to `https://cdn-api.swissttx.ch` and is not required.

- Type: `String`