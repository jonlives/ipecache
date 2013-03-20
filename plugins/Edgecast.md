Edgecast
========
Purges URLS from the Edgecast CDN - please note this currently only works with HTTP Small objects.

Hooks
-----
- `cdn_purge`

Configuration
-------------
```yaml
plugins:
  edgecast:
    account_id: 1ABC
    api_key: aaaa-aaaaaa-aaaaaa-aaaaa
```

#### account_id
This is your Edgecast account number, found at the top of the Edgecast admin interface

- Type: `String`

#### api_key
This is your Edgecast API key

- Type: `String`
