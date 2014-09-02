require 'ipecache/plugins/plugin'

module Ipecache
  module Plugins
    class SwisstxtCdn < Plugin
      name :swisstxt_cdn
      hooks :cdn_purge

      def perform
        safe_require 'uri'
        safe_require 'faraday_middleware'

        plugin_puts "Beginning URL Purge from SWISS TXT CDN..."

        urls.each do |u|
          url = u.chomp
          plugin_puts ("Purging #{url}")

          begin
            conn = connection
            unless host = URI.parse(url).host
              raise "Invalid URL: No host found in URL. Missing schema?"
            end
            path = URI.parse(url).path
            response = conn.post('/purge', host: host, path: path)
          rescue => e
            plugin_puts_error(url, e.message)
            continue_on_error ? next : exit(1)
          end

          if response.status != 200
            plugin_puts_error(url, "Response Code: #{response.status}")
            plugin_puts_error(url, response.body['error'] || response.body)
            exit 1 unless continue_on_error
          else
            plugin_puts "Purge successful!"
          end
        end
      end

      def connection
        if config.api_key.nil?
          plugin_puts("SWISS TXT CDN API api_key not specified, Exiting...")
          exit 1
        end

        if config.api_secret.nil?
          plugin_puts("SWISS TXT CDN API api_secret not specified, Exiting...")
          exit 1
        end

        Faraday.new(url: config.url || 'https://cdn-api.swisstxt.ch') do |conn|
          conn.request :url_encoded
          conn.headers[:user_agent]     = 'Ipecache'
          conn.headers[:accept]         = 'application/json'
          conn.response :json, content_type: /\b(json)$/
          conn.headers['X-API-KEY']     = config.api_key
          conn.headers['X-API-SECRET']  = config.api_secret
          conn.adapter Faraday.default_adapter
        end
      end
    end
  end
end
