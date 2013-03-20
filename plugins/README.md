Plugins Directory
=================
This folder contains relevant documentation for each KnifeSpork plugin. For more information, usage, and options for an particular plugin, click on the assoicated markdown file in the tree above.

Creating a Plugin
-----------------
To create a plugin, start with the following basic boiler template:

```ruby
require 'ipecache/plugins/plugin'

module Ipecache
  module Plugins
    class MyPlugin < Plugin
      name :my_plugin
      hooks :my_hooks

      def perform
        # your plugin code here
      end
    end
  end
end
```

**Don't forget to update the class name and the `name` at the very top of the class!**

Hooks
-----

Currently, the only hooks called by the ipecache binary are "proxy_purge" (for plugins for "local" proxy servers) and "cdn_purge" (for CDN plugins). These hooks determine whether or not your plugin will be called when the -c and -p options are passed to the ipecache binary.

Helpers
-------
The following "helpers" or "methods" are exposed:

#### safe_require
This method allows you to safely require a gem. This is helpful when your plugin requires an external plugin. It will output a nice error message if the gem cannot be loaded and stop executing.

#### urls
This method gives you the list of URLS to be purged

#### plugin_puts
This method prints strings prefixed by the class name of your plugin, for clarity of output

#### config
This method returns the config associated with the current plugin. For example, if a `spork-config.yml` file looked like this:

```yaml
plugins:
  my_plugin:
    option_1: my_value
    option_2: other_value
```

then

```text
config.option_1   #=> 'my_value'
config.option_2   #=> 'other_value'
```

This uses `app_conf`, so you access the keys as methods, not `[]`.