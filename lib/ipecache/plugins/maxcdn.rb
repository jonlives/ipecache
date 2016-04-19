require 'ipecache/plugins/plugin'

module Ipecache
  module Plugins
    class MaxCDN < Plugin
      name :maxcdn
      hooks :cdn_purge

      def perform
        safe_require 'maxcdn'

        [ :alias, :token, :secret, :zone ].each do |key|
          confirm!(key)
        end

        zone = config.zone.to_i

        plugin_puts "Beginning URL Purge from MaxCDN..."

        api = ::MaxCDN::Client.new(config.alias, config.token, config.secret)

        urls.each do |u|
          url = u.chomp
          plugin_puts ("Purging #{url}")

          begin
            response = api.purge(zone, url)

            if response["code"] != 200
              plugin_puts_error(url, "Response Code: #{response["code"]}")
              plugin_puts_error(url, response.to_s)
              exit 1 unless continue_on_error
            else
              plugin_puts "Purge successful!"
            end
          rescue MaxCDN::APIException => e
            plugin_puts_error(url, "Response: #{e}")
            exit 1 unless continue_on_error
          end
        end
      end

      private
      def confirm! key
        if config.send(key).nil?
          plugin_puts("MaxCDN #{key} not specified, Exiting...")
          exit 1
        end
      end

    end
  end
end
