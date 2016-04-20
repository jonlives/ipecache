Varnish
========
Uses a defined set of Hosts from the config and purges/bans the URL list from each Varnish Server
Adapted from the Local plugin

Hooks
-----
- `proxy_purge`

Configuration
-------------
```yaml
plugins:
  varnish:
    hosts:
      - cache1.mydomain.com
      - cache2.mydomain.com
    use_ssh: false
    action: ban
    auth_key: <authapikey>
```

#### hosts
This defines an array of Hosts to send the purge request

- Type: `Array`

#### use_ssh
This enables a SSH-Wrapper to run the purge request locally on the Cache Server

- Type: `Boolean`

#### action
This defines whether use BAN or PURGE

- Type: `String`

### auth_key
This defines the authorization key sent in the headers with the request

- Type: `String`
