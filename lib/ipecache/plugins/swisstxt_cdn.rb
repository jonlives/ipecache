require 'ipecache/plugins/plugin'

module Ipecache
  module Plugins
    class SwisstxtCdn < Plugin
      name :swisstxt_cdn
      hooks :cdn_purge

      def perform
        safe_require 'uri'
        safe_require 'json'
        safe_require 'uri'
        safe_require 'faraday_middleware'

        api_key     = config.api_key
        api_secret  = config.api_secret

        if api_key.nil?
          plugin_puts("SWISS TXT CDN API api_key not specified, Exiting...")
          exit 1
        end

        if api_secret.nil?
          plugin_puts("SWISS TXT CDN API api_secret not specified, Exiting...")
          exit 1
        end

        plugin_puts "Beginning URL Purge from SWISS TXT CDN..."

        connection = Faraday.new(url: "https://api.cdn.swissttx.ch") do |faraday|
          faraday.request  :url_encoded
          faraday.request  :json
          faraday.adapter  Faraday.default_adapter
          faraday.headers[:user_agent] = 'Ipecache'
          faraday.response :json, content_type: /\b(json)$/
          faraday.headers['X-API-KEY']     = api_key
          faraday.headers['X-API-SECRET']  = api_secret
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