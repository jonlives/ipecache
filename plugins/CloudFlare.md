CloudFlare
==========
Purge URLs from the CloudFlare CDN.

Hooks
-----
- `cdn_purge`

Configuration
-------------
```yaml
plugins:
  cloudflare:
    login: foo@bar.com
    api_key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

#### login
This is your standard CloudFlare login.

- Type: `String`

#### api_key
Associated API Key, available on the "Account" page.

- Type: `String`
