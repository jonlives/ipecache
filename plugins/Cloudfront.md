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
    region: eu-west-1
    batch_size: 3000
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

### region
This is the AWS region of your CF distributions

- Type `String`

### batch_size
This is the number of items to be included for each invalidation request, default to 3000 (aws max limit)

- Type `Integer`
