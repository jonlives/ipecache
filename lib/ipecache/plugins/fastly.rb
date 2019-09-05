require 'ipecache/plugins/plugin'
require 'net/http'

module Ipecache
  module Plugins
    class Fastly < Plugin
      name :fastly
      hooks :cdn_purge

      def perform
        safe_require 'uri'
        safe_require 'openssl'
        api_key = config.api_key

        if api_key.nil?
          plugin_puts("Fastly API key not specified, Exiting...")
          exit 1
        end

        plugin_puts "Beginning URL Purge from Fastly..."

        urls.each do |u|
          url = u.chomp
          plugin_puts ("Purging #{url}")

          uri = URI.parse("https://api.fastly.com/purge/#{url}")

          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true

          http.verify_mode = OpenSSL::SSL::VERIFY_PEER

          request = Net::HTTP::Post.new(uri.request_uri)
          request.add_field("Accept", "application/json")
          request.add_field("User-Agent", "Ipecache")
          request.add_field("Fastly-Key", api_key)

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
