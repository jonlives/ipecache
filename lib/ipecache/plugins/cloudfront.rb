require 'ipecache/plugins/plugin'

module Ipecache
  module Plugins
    class CloudFront < Plugin
      name :cloudfront
      hooks :cdn_purge

      def perform
        safe_require 'aws-sdk-v1'
        safe_require 'uri'

        access_key_id = config.access_key_id
        secret_access_key = config.secret_access_key
        region = config.region
        distributions = config.distributions
        batch_size = config.batch_size || 3000

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

        if region.nil?
          plugin_puts "Cloudfront region not specified, Exiting..."
          exit 1
        end

        plugin_puts "Beginning URL Purge from CloudFront..."

        AWS.config(
        :access_key_id => access_key_id,
        :secret_access_key => secret_access_key,
        :region => region
        )
        cf = AWS::CloudFront.new()

        urls.each_slice(batch_size) do |u|
          paths = []
          u.each { |x| paths << URI.parse(x).path}
          distributions.each do |distri|
            plugin_puts "Purging #{u.length} items from #{distri}"
            result = cf.client.create_invalidation(
              :distribution_id => distri,
              :invalidation_batch => {
                :paths => {
                  :quantity => paths.length,
                  :items => paths
                },
                :caller_reference => "Ipecache_#{Time.now}"
              }
            )
            plugin_puts "#{result[:id]}: #{result[:status]}, #{result[:invalidation_batch][:paths][:items].length} item(s)"
          end
          plugin_puts "This invalidation costs #{paths.length*0.005} Euro"
        end
      end
    end
  end
end
