require 'ipecache/plugins/plugin'

module Ipecache
  module Plugins
    class Varnish < Plugin
      name :varnish
      hooks :proxy_purge

      def perform
        safe_require 'uri'

        hosts = config.hosts
        use_ssh = config.use_ssh
        action = (config.action.upcase == "PURGE") ? "PURGE" : "BAN"
        key = config.auth_key

        if !hosts
          plugin_puts "No hosts in config file specified. Exiting..."
          exit 1
        end

        request = (action == "BAN") ? "Banning" : "Purging"

        with = (use_ssh) ? "ssh curl" : "curl";

        urls.each do |u|
          url = u.chomp.gsub(/\*$/,'').gsub(/\*/,'.*')
          plugin_puts ("#{request} #{url} through #{with}")
          hosts.each do |varnish|
            hostname = URI.parse(url).host
            path = URI.parse(url).path
            if use_ssh
              result = `ssh #{varnish} 'curl -X #{action} -s -o /dev/null -w \"%{http_code}\" --header \"X-BAN-Auth: #{key}\" --header \"Host: #{hostname}\" \"http://localhost#{path}\"'`
            else
              result = `curl -X #{action} -s -o /dev/null -w "%{http_code}" --header "X-BAN-Auth: #{key}" --header "Host: #{hostname}" "http://#{varnish}#{path}"`
            end
            if result.include?("200")
              plugin_puts "--#{request} from #{varnish} sucessfully"
            elsif result.include?("404")
              plugin_puts "--#{action} from #{varnish} not needed, asset not found"
            else
              plugin_puts_error(url,"--#{action} from #{varnish} failed with http_code = #{result}")
            end

          end
        end
      end
    end
  end
end
