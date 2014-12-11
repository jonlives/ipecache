CloudFront
==========
Purge URLs from the CloudFront CDN.

Hooks
-----
- `cdn_purge`

Configuration
-------------
```yaml
plugins:
  cloudfront:
    access_key_id: yyyyyyyyyyyyyyyy
    secret_access_key: xxxxxxxxxxxxxxxxxx
    distributions:
        - distribution1
        - distribution2
```

#### access_key_id
This is your aws access id

- Type: `String`

#### secret_access_key
This is your aws access key

- Type: `String`

#### distributions
This is a list of CF distributions

- Type `Array`
