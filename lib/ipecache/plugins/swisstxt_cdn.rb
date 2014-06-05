require 'ipecache/plugins/plugin'

module Ipecache
  module Plugins
    class SwisstxtCdn < Plugin
      name :swisstxt_cdn
      hooks :cdn_purge

      def perform
        safe_require 'uri'
        safe_require 'json'
        safe_require 'faraday'
        safe_require 'faraday/digestauth'

        user = config.user
        password = config.password

        if user.nil?
          plugin_puts("SWISS TXT CDN API user not specified, Exiting...")
          exit 1
        end

        if password.nil?
          plugin_puts("SWISS TXT CDN API password not specified, Exiting...")
          exit 1
        end

        plugin_puts "Beginning URL Purge from SWISS TXT CDN..."

        connection = Faraday.new(url: "https://api.cdn.swissttx.ch") do |faraday|
          faraday.request  :url_encoded
          faraday.request  :digest, user, password
          faraday.adapter  Faraday.default_adapter
          faraday.headers[:user_agent] = 'Ipecache'
        end

        urls.each do |u|
          url = u.chomp
          host = URI.parse(url).host
          path = URI.parse(url).path

          plugin_puts ("Purging #{url}")

          response = connection.post '/purge', { 
            host: => host,
            path: => path
          }

          if response.status != 200
            plugin_puts_error(url,"Response Code: #{response.status}")
            plugin_puts_error(url,response.body)
            exit 1 unless continue_on_error
          else
            plugin_puts "Purge successful!"
          end
        end
      end
    end
  end
end