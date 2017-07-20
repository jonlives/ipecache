require 'ipecache/plugins/plugin'

module Ipecache
  module Plugins
    class Akamai < Plugin
      name :akamai
      hooks :cdn_purge

      def perform
        safe_require 'faraday_middleware'
        safe_require 'json'

        username = config.username
        password = config.password

        if username.nil?
          plugin_puts("Akamai username not specified, Exiting...")
          exit 1
        end

        if password.nil?
          plugin_puts("Akamai password key not specified, Exiting...")
          exit 1
        end

        plugin_puts "Beginning URL Purge from Akamai..."

        urls.each do |u|
          url = u.chomp
          plugin_puts ("Purging #{url}")

          connection = Faraday::Connection.new(
              {:url => "https://api.ccu.akamai.com",
              :headers => { :accept =>  'application/json',
                            :content_type =>  'application/json',
                            :user_agent => 'Ipecache',
                          },
              :ssl => { :verify => true }
              }) do |builder|
            builder.request  :json
            builder.basic_auth(username,password)
            builder.adapter Faraday.default_adapter
          end

          response = connection.post("/ccu/v2/queues/default", "{\"objects\":[\"#{url}\"]}")

          response_json = JSON.parse(response.body)
          response_httpStatus = response_json['httpStatus']
          response_progressUri = response_json['progressUri']

          if response_httpStatus != 201
            plugin_puts_error(url,"Purge failed!")
            plugin_puts response.body
            exit 1 unless continue_on_error
          else
            plugin_puts "Purge successful! [progressUri: https://api.ccu.akamai.com#{response_progressUri}]"
          end
        end
      end
    end
  end
end
