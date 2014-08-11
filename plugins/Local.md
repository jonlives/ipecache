Local
========
Uses a defined set of Hosts from the config and purges the URL list from each Cache Server e.g. Apache Traffic Server or Varnish Cache

Hooks
-----
- `proxy_purge`

Configuration
-------------
```yaml
plugins:
  local:
    hosts: 
      - cache1.mydomain.com
      - cache2.mydomain.com
    use_ssh: false
```

#### hosts
This defines an array of Hosts to send the purge request

- Type: `Array`

#### use_ssh
This enables a SSH-Wrapper to run the purge request locally on the Cache Server 

- Type: `Boolean`
