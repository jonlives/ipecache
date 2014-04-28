require 'ipecache/plugins/plugin'

module Ipecache
  module Plugins
    class Edgecast < Plugin
      name :edgecast
      hooks :cdn_purge

      def perform
        safe_require 'uri'
        safe_require 'faraday_middleware'
        safe_require 'json'

        account_id = config.account_id
        api_key = config.api_key

        if account_id.nil?
          plugin_puts("Edgecast account id not specified, Exiting...")
          exit 1
        end

        if api_key.nil?
          plugin_puts("Edgecast API key not specified, Exiting...")
          exit 1
        end

        plugin_puts "Beginning URL Purge from Edgecast..."

        urls.each do |u|
          url = u.chomp
          plugin_puts ("Purging #{url}")

          connection = Faraday::Connection.new(
              {:url => "https://api.edgecast.com",
              :headers => { :accept =>  'application/json',
                            :content_type =>  'application/json',
                            :user_agent => 'Ipecache',
                            :authorization => "TOK:#{api_key}"},
              :ssl => { :verify => true }
              }) do |builder|
            builder.request  :json
            builder.adapter Faraday.default_adapter
          end

          response = connection.put("/v2/mcc/customers/#{account_id}/edge/purge",{ :MediaPath => url, :MediaType => 8})

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
