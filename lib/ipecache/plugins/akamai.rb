require 'ipecache/plugins/plugin'

module Ipecache
  module Plugins
    class AKAMAI < Plugin
      name :akamai
      hooks :cdn_purge

      def perform
        safe_require 'json'
        safe_require 'akamai/edgegrid'
        safe_require 'net/http'
        safe_require 'uri'

        client_secret = config.client_secret
        host = config.host
        access_token = config.access_token
        client_token = config.client_token

        if client_secret.nil?
          plugin_puts("Akamai client_secret not specified, Exiting...")
          exit 1
        end

        if host.nil?
          plugin_puts("Akamai host not specified, Exiting...")
          exit 1
        end

        if access_token.nil?
          plugin_puts("Akamai access_token not specified, Exiting...")
          exit 1
        end

        if client_token.nil?
          plugin_puts("Akamai client_token not specified, Exiting...")
          exit 1
        end

        plugin_puts "Beginning URL Purge from Akamai..."

        baseuri = URI("https://#{host}/")

        http = Akamai::Edgegrid::HTTP.new(
          address=baseuri.host,
          port=baseuri.port
        )

        http.setup_edgegrid(
          :client_token => client_token,
          :client_secret => client_secret,
          :access_token => access_token,
          :max_body => 128 * 1024
        )

        urls.each do |u|
          url = u.chomp
          plugin_puts ("Purging #{url}")

          post_request = Net::HTTP::Post.new(
            URI.join(baseuri.to_s, "/ccu/v3/delete/url/production").to_s,
            initheader = { 'Content-Type' => 'application/json' }
          )

          post_request.body = {
            "objects" => ["#{url}"]
          }.to_json

          response = http.request(post_request)

          response_json = JSON.parse(response.body)
          response_httpStatus = response_json['httpStatus']

          if response_httpStatus != 201
            plugin_puts_error(url,"Purge failed!")
            plugin_puts response.body
            exit 1 unless continue_on_error
          else
            plugin_puts "Purge successful!"
          end
        end
      end
    end
  end
end
