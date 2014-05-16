require 'ipecache/plugins/plugin'


module Ipecache
  module Plugins
    class AkamaiEdgegrid < Plugin
      name :akamai_edgegrid
      hooks :cdn_purge

      def perform
        safe_require 'faraday_middleware'
        safe_require 'json'

        safe_require 'akamai/edgegrid'
        safe_require 'net/http'
        safe_require 'uri'

        base_uri = URI.parse(config.base_uri)
        client_token = config.client_token
        client_secret = config.client_secret
        access_token = config.access_token


        if base_uri.nil?
          plugin_puts("Akamai Edgegrid base_uri not specified, Exiting...")
          exit 1
        end

        if client_token.nil?
          plugin_puts("Akamai Edgegrid client_token not specified, Exiting...")
          exit 1
        end

        if client_secret.nil?
          plugin_puts("Akamai Edgegrid client_secret not specified, Exiting...")
          exit 1
        end

        if access_token.nil?
          plugin_puts("Akamai Edgegrid access_token not specified, Exiting...")
          exit 1
        end

        plugin_puts "Beginning URL Purge from Akamai..."

        urls.each do |u|
          url = u.chomp
          plugin_puts ("Purging #{url}")

          http = Akamai::Edgegrid::HTTP.new(
              address=base_uri.host,
              post=base_uri.port
          )

          http.setup_edgegrid(
              :client_token => client_token,
              :client_secret => client_secret,
              :access_token => access_token
          )


          request = Net::HTTP::Post.new URI.join(base_uri.to_s, '/ccu/v2/queues/default').to_s
          request.set_form_data({"objects" =>["#{url}"]})
          response = http.request(request)

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
