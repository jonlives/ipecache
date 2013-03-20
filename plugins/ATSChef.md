ATSChef
========
Queries chef for nodes in the specified role and purges the URL list from each Apache Traffic Server

Gem Requirements
----------------
This plugin requires the following gems:

```ruby
gem 'chef'
```

Hooks
-----
- `proxy_purge`

Configuration
-------------
```yaml
plugins:
  atschef:
    knife_config: /my/.chef/knife.rb
    chef_role: ATSRole
```

#### knife_config
This is the knife.rb that ipecache can use to search against your Chef server

- Type: `String`

#### chef_role
This is the chef role which your ATS servers live in

- Type: `String`
