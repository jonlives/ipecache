Akamai
========
Purges URLS from the Akamai CDN using the Content Control Utility API

Hooks
-----
- `cdn_purge`

Configuration
-------------
```yaml
plugins:
  akamai:
    client_secret: xxxxxxx
    host: xxxxxxx
    access_token: xxxxxxx
    client_token: xxxxxxx
```

#### username
This is the username of the Akamai account you want to use

- Type: `String`

#### password
This is the password of the Akamai account you want to use

- Type: `String`
