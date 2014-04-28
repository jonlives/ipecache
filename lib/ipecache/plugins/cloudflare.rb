require 'ipecache/plugins/plugin'

module Ipecache
  module Plugins
    class CloudFlare < Plugin
      name :cloudflare
      hooks :cdn_purge

      def perform
        safe_require 'uri'
        safe_require 'faraday_middleware'
        safe_require 'json'
        safe_require 'public_suffix'

        login = config.login
        api_key = config.api_key

        if login.nil?
          plugin_puts "CloudFlare login not specified, Exiting..."
          exit 1
        end

        if api_key.nil?
          plugin_puts "CloudFlare API key not specified, Exiting..."
          exit 1
        end

        plugin_puts "Beginning URL Purge from CloudFlare..."

        urls.each do |u|
          url = u.chomp
          plugin_puts  "Purging #{url}"

          uri = URI.parse(url)
          zone = PublicSuffix.parse(uri.host).domain

          connection = Faraday::Connection.new(
              {:url => "https://www.cloudflare.com",
              :headers => { :accept =>  'application/json',
                            :user_agent => 'Ipecache'
                          },
              :ssl => { :verify => true }
              }) do |builder|
            builder.request  :url_encoded
            builder.adapter Faraday.default_adapter
          end

          response = connection.get("/api_json.html",
            { :act    => 'zone_file_purge',
              :tkn    => api_key,
              :email  => login,
              :z      => zone,
              :url    => url
            })

          response_json = JSON.parse(response.body)
          response_result = response_json['result']

          if response_result != 'success'
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
