require 'ipecache/plugins/plugin'

module Ipecache
  module Plugins
    class ATSChef < Plugin
      name :atschef
      hooks :proxy_purge

      def perform
        safe_require 'chef'
        safe_require 'uri'

        knife_file = config.knife_config || ""
        chef_role = config.chef_role

        if knife_file.empty?
          plugin_puts "No knife config file specified. Exiting..."
          exit 1
        elsif File.exists?(knife_file)
          Chef::Config.from_file(knife_file)
          rest_api = Chef::ServerAPI.new(Chef::Config[:chef_server_url])
        else
          plugin_puts "Knife config file #{knife_file} doesn't exist."
          exit 1
        end

        if !chef_role
          plugin_puts "Chef role not specified, Exiting..."
          exit 1
        end

        plugin_puts "Beginning URL Purge from ATS..."
        plugin_puts "Finding ATS Servers..."
        nodes_ats_fqdns = []
        nodes_ats = rest_api.get_rest("/search/node?q=role:#{chef_role}" )
        nodes_ats["rows"].each do |n|
          nodes_ats_fqdns <<  n['automatic']['fqdn'] unless n.nil?
        end

        urls.each do |u|
          url = u.chomp
          plugin_puts "Purging #{url}"
          nodes_ats_fqdns.each do |ats|
            hostname = URI.parse(url).host
            path = URI.parse(url).path
            result = `ssh #{ats} 'curl -X PURGE -s -o /dev/null -w \"%{http_code}\" --header \"Host: #{hostname}\" \"http://localhost#{path}\"'`
            if result.include?("200")
              plugin_puts "--Purged from #{ats} sucessfully"
            elsif result.include?("404")
              plugin_puts "--Purge from #{ats} not needed, asset not found"
            else
              plugin_puts_error(url,"--Purge from #{ats} failed")
            end

          end
        end
      end
    end
  end
end
