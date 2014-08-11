require 'ipecache/plugins/plugin'

module Ipecache
  module Plugins
    class Local < Plugin
      name :local
      hooks :proxy_purge

      def perform
        safe_require 'uri'

        hosts = config.hosts
        use_ssh = config.use_ssh

        if !hosts
          plugin_puts "No hosts in config file specified. Exiting..."
          exit 1
        end

        with = (use_ssh) ? "ssh curl" : "curl";
        
        urls.each do |u|
          url = u.chomp
          plugin_puts ("Purging #{url} through #{with}")
          hosts.each do |local|
            hostname = URI.parse(url).host
            path = URI.parse(url).path
            if use_ssh
              result = `ssh #{local} 'curl -X PURGE -s -o /dev/null -w \"%{http_code}\" --header \"Host: #{hostname}\" \"http://localhost#{path}\"'`
            else
              result = `curl -X PURGE -s -o /dev/null -w "%{http_code}" --header "Host: #{hostname}" "http://#{local}#{path}"`
            end
            if result.include?("200")
              plugin_puts "--Purged from #{local} sucessfully"
            elsif result.include?("404")
              plugin_puts "--Purge from #{local} not needed, asset not found"
            else
              plugin_puts_error(url,"--Purge from #{local} failed with http_code = #{result}")
            end

          end
        end
      end
    end
  end
end
