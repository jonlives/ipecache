Ipecache
===========
Ipecache is an extensible tool for purging URLs from Caches and CDNs.

Installation
------------
### Gem Install (recommended)
`ipecache` is available on rubygems. Add the following to your `Gemfile`:

```ruby
gem 'ipecache'
```

or install the gem manually:

```bash
gem install ipecache
```

Ipecache Configuration
-------------------
Ipecache will not work with no configuration, so before you can purge anything, you'll need to specify some configuration for the plugins you wish to use.

Ipecache will look for a configuration file in the following locations, in ascending order of precedence:

- `/etc/ipecache-config.yml`
- `~/.ipecache/ipecache-config.yml`

Anything set in the configuration file in your home directory for example, will override options set in `/etc`.

Below is a sample config file with all supported options and all shipped plugins enabled below, followed by an explanation of each section.

Please note, if you do not want to use a particular plugin, don't specify any configuration for it and it will automatically be disabled.

```yaml
plugins:
  atschef:
    knife_config: /my/.chef/knife.rb
    chef_role: ATSRole
  fastly:
    api_key: abc123abc123abc123abc123abc123abc123
  edgecast:
    account_id: 1A2B
    api_key: abc123
  maxcdn:
    alias: myalias
    token: 1A2B
    secret: abc123
    zone: 1234
  akamai:
    client_secret: xxxxxxx
    host: xxxxxxx
    access_token: xxxxxxx
    client_token: xxxxxxx
  cloudflare:
    login: foo@bar.com
    api_key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  local:
    hosts:
      - cache1.mydomain.com
      - cache2.mydomain.com
    use_ssh: false
  swisstxt_cdn:
    api_key: sample_key_e8e55aff-61e3-4588-ab98-4d3ea58be7c8
    api_secret: xyz5678xyz5678xyz5678xyz5678xyz5678xyz5678xyz5678
  cloudfront:
    access_key_id: yyyyyyyyyyyyyyyy
    secret_access_key: xxxxxxxxxxxxxxxxxx
    region: eu-west-1
    batch_size: 3000
    distributions:
      - distribution1
      - distribution2
```

#### atschef
For more information on how to configure the ATS/Chef plugin, please read the [plugins/ATSChef.md](plugins/ATSChef.md) file.

#### Fastly
For more information on how to configure the Fastly CDN plugin, please read the [plugins/Fastly.md](plugins/Fastly.md) file.

#### Edgecast
For more information on how to configure the Edgecast CDN plugin, please read the [plugins/Edgecast.md](plugins/Edgecast.md) file.

#### Akamai
For more information on how to configure the Akamai plugin, please read the [plugins/Akamai.md](plugins/Akamai.md) file.

#### CloudFlare
For more information on how to configure the CloudFlare plugin, please read the [plugins/CloudFlare.md](plugins/CloudFlare.md) file.

#### Local
For more information on how to configure the Local plugin, please read the [plugins/Local.md](plugins/Local.md) file.

#### SWISS TXT CDN
For more information on how to configure the SWISS TXT CDN plugin, please read the [plugins/SWISS_TXT_CDN.md](plugins/SWISS_TXT_CDN.md) file.

#### Amazon Cloudfront
For more information on how to configure the Amazon Cloudfront CDN plugin, please read the [plugins/Cloudfront.md](plugins/Cloudfront.md) file.

#### MaxCDN
For more information on how to configure the MaxCDN plugin, please read the [plugins/MaxCDN.md](plugins/MaxCDN.md) file.

Ipecache Usage
-----------
The main component of Ipecache, and the program which initialises and calls all plugins is called `ipecache`.

#### Usage
```bash
ipecache [-f -u -c -p -l -q --status]
```

* Mandatory Parameters (you must specify one or the other)
    * -f: Specifies a file containg a newline seperated list of URLS to purge
    * -u: Specifies a single URL to purge

* Optional Parameters:
    * --status: Prints the status of all ipecache plugins
    * -c: Indicates that only CDN plugins should be run
    * -p: Indicates that only local proxy plugins should be run.
    * -l: Specify a file to log errors to
    * -n, --nofail: Do not quit on error, continue purging
    * -q, --quiet: Suppress all console output


#### Example (Checking plugin status)

```text
$> ipecache --status
Ipecache Status:

Ipecache::Plugins::Akamai: enabled
Ipecache::Plugins::ATSChef: enabled
Ipecache::Plugins::Edgecast: enabled
Ipecache::Plugins::Fastly: enabled
Ipecache::Plugins::Local: enabled
```

#### Example (Purging a single URL from local proxies only)

```text
$> ipecache -u https://img3.etsystatic.com/000/0/5241384/il_340x270.220445599.jpg -p

Running plugins registered for Proxy Purge...


Ipecache::Plugins::ATSChef: Beginning URL Purge from ATS...
Ipecache::Plugins::ATSChef: Finding ATS Servers...
Ipecache::Plugins::ATSChef: Purging https://img.mydomain.com/image9.jpg
Ipecache::Plugins::ATSChef: --Purge from cache1.mydomain.com not needed, asset not found
Ipecache::Plugins::ATSChef: --Purged from cache2.mydomain.com sucessfully

All done!
```

#### Example (Purging a file containing 2 URLs from CDNS only)

```text
$>  ipecache -f ~/urlfile -c

   Running plugins registered for CDN Purge...


   Ipecache::Plugins::Akamai: Beginning URL Purge from Akamai...
   Ipecache::Plugins::Akamai: Purging https://img.mydomain.com/image9.jpg
   Ipecache::Plugins::Akamai: Purge successful!
   Ipecache::Plugins::Akamai: Purging https://img.mydomain.com/image10.jpg
   Ipecache::Plugins::Akamai: Purge successful!

   Ipecache::Plugins::Edgecast: Beginning URL Purge from Edgecast...
   Ipecache::Plugins::Edgecast: Purging https://img.mydomain.com/image9.jpg
   Ipecache::Plugins::Edgecast: Purge successful!
   Ipecache::Plugins::Edgecast: Purging https://img.mydomain.com/image10.jpg
   Ipecache::Plugins::Edgecast: Purge successful!

   Ipecache::Plugins::Fastly: Beginning URL Purge from Fastly...
   Ipecache::Plugins::Fastly: Purging https://img.mydomain.com/image9.jpg
   Ipecache::Plugins::Fastly: Purge successful!
   Ipecache::Plugins::Fastly: Purging https://img.mydomain.com/imag10.jpg
   Ipecache::Plugins::Fastly: Purge successful!

   All done!
```

#### Example (Purging a file containing 2 URLs from proxies and CDNS)

```text
$>  ipecache -f ~/urlfile

   Running plugins registered for Proxy Purge...


   Ipecache::Plugins::ATSChef: Beginning URL Purge from ATS...
   Ipecache::Plugins::ATSChef: Finding ATS Servers...
   Ipecache::Plugins::ATSChef: Purging https://img.mydomain.com/image9.jpg
   Ipecache::Plugins::ATSChef: --Purge from cache1.mydomain.com not needed, asset not found
   Ipecache::Plugins::ATSChef: --Purged from cache2.mydomain.com sucessfully
   Ipecache::Plugins::ATSChef: Purging https://img.mydomain.com/image10.jpg
   Ipecache::Plugins::ATSChef: --Purge from cache1.mydomain.com not needed, asset not found
   Ipecache::Plugins::ATSChef: --Purged from cache2.mydomain.com sucessfully

   Running plugins registered for CDN Purge...


   Ipecache::Plugins::Akamai: Beginning URL Purge from Akamai...
   Ipecache::Plugins::Akamai: Purging https://img.mydomain.com/image9.jpg
   Ipecache::Plugins::Akamai: Purge successful!
   Ipecache::Plugins::Akamai: Purging https://img.mydomain.com/image10.jpg
   Ipecache::Plugins::Akamai: Purge successful!

   Ipecache::Plugins::Edgecast: Beginning URL Purge from Edgecast...
   Ipecache::Plugins::Edgecast: Purging https://img.mydomain.com/image9.jpg
   Ipecache::Plugins::Edgecast: Purge successful!
   Ipecache::Plugins::Edgecast: Purging https://img.mydomain.com/image10.jpg
   Ipecache::Plugins::Edgecast: Purge successful!

   Ipecache::Plugins::Fastly: Beginning URL Purge from Fastly...
   Ipecache::Plugins::Fastly: Purging https://img.mydomain.com/image9.jpg
   Ipecache::Plugins::Fastly: Purge successful!
   Ipecache::Plugins::Fastly: Purging https://img.mydomain.com/imag10.jpg
   Ipecache::Plugins::Fastly: Purge successful!

   All done!
```
