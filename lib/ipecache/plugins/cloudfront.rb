require 'ipecache/plugins/plugin'

module Ipecache
  module Plugins
    class CloudFront < Plugin
      name :cloudfront
      hooks :cdn_purge

      def perform
        safe_require 'aws-sdk'
        safe_require 'uri'

        access_key_id = config.access_key_id
        secret_access_key = config.secret_access_key
        distributions = config.distributions

        if access_key_id.nil?
          plugin_puts "Cloudfront access id not specified, Exiting..."
          exit 1
        end

        if secret_access_key.nil?
          plugin_puts "Cloudfront access key not specified, Exiting..."
          exit 1
        end

        if distributions.nil?
          plugin_puts "Cloudfront distributions not specified, Exiting..."
          exit 1
        end

        plugin_puts "Beginning URL Purge from CloudFront..."

        cf = AWS::CloudFront.new(
        :access_key_id => access_key_id,
        :secret_access_key => secret_access_key)

        urls.each do |u|
          url = u.chomp
          distributions.each do |distri|
            plugin_puts "Purging #{url} on #{distri}"
            uri = URI.parse(url)
            result = cf.client.create_invalidation(
              :distribution_id => distri,
              :invalidation_batch => {
                :paths => {
                  :quantity => 1,
                  :items => Array(uri)
                },
                :caller_reference => "Ipecache_#{Time.now}"
              }
            )
            plugin_puts result[:status]
          end
        end
      end
    end
  end
end
