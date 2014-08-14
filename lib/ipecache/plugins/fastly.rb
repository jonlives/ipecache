require 'ipecache/plugins/plugin'
require 'net/http'

module Ipecache
  module Plugins
    class Fastly < Plugin
      name :fastly
      hooks :cdn_purge

      def perform
        safe_require 'uri'

        api_key = config.api_key

        if api_key.nil?
          plugin_puts("Fastly API key not specified, Exiting...")
          exit 1
        end

        plugin_puts "Beginning URL Purge from Fastly..."

        urls.each do |u|
          url = u.chomp
          plugin_puts ("Purging #{url}")
          hostname = URI.parse(url).host
          path = URI.parse(url).path

          http = Net::HTTP.new("api.fastly.com", "443")
          http.use_ssl = true
          http.ssl_version = 'SSLv3'
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE

          request = Net::HTTP::Purge.new(path)
          request.add_field("X-Forwarded-For", "0.0.0.0")
          request.add_field("Accept", "application/json")
          request.add_field("User-Agent", "Ipecache")
          request.add_field("Content-Type", "application/x-www-form-urlencoded")
          request.add_field("X-Fastly-Key", api_key)
          request.add_field("Host", hostname)

          response = http.request(request)

          if response.code.to_i != 200
            plugin_puts_error(url,"Response Code: #{response.code}")
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

class Net::HTTP::Purge < Net::HTTPRequest
  METHOD = 'PURGE'
  REQUEST_HAS_BODY = false
  RESPONSE_HAS_BODY = true
end
