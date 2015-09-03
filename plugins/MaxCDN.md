MaxCDN
========
Purges URLS from MaxCDN

Hooks
-----
- `cdn_purge`

Configuration
-------------
```yaml
plugins:
   maxcdn:
     alias: myalias
     token: 1A2B
     secret: abc123
     zone: 1234
```

#### api_key
This is your fastly API key

- Type: `String`
