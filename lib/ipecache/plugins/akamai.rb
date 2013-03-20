require 'ipecache/plugins/plugin'

module Ipecache
  module Plugins
    class Akamai < Plugin
      name :akamai
      hooks :cdn_purge

      def perform
        safe_require 'savon'

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

        puts ""
        plugin_puts "Beginning URL Purge from Akamai..."

        urls.each do |u|
          url = u.chomp
          plugin_puts ("Purging #{url}")

          savon_client = Savon.client({log_level: :info, log: false, convert_request_keys_to: :none,  wsdl: 'https://ccuapi.akamai.com/ccuapi-axis.wsdl'})
          response = savon_client.call(:purge_request, xml: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
                                                             <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
                                                                  xmlns:soapenc=\"http://schemas.xmlsoap.org/soap/encoding/\"
                                                                  xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"
                                                                  soap:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"
                                                                  xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">
                                                                  <soap:Body>
                                                                      <purgeRequest xmlns=\"http://ccuapi.akamai.com/purge\">
                                                                          <name xsi:type=\"xsd:string\">#{username}</name>
                                                                          <pwd xsi:type=\"xsd:string\">#{password}</pwd>
                                                                          <network xsi:type=\"xsd:string\"></network>
                                                                          <opt soapenc:arrayType=\"xsd:string[2]\" xsi:type=\"soapenc:Array\">
                                                                              <item xsi:type=\"xsd:string\">type=arl</item>
                                                                              <item xsi:type=\"xsd:string\">action=remove</item>
                                                                          </opt>'
                                                                          <uri soapenc:arrayType=\"xsd:string[1]\" xsi:type=\"soapenc:Array\">
                                                                            <item xsi:type=\"xsd:string\">#{url}</item>
                                                                          </uri>
                                                                      </purgeRequest>
                                                                  </soap:Body>
                                                              </soap:Envelope>")
          response_hash = response.to_hash
          if response_hash[:purge_request_response][:return][:result_msg] != "Success."
            plugin_puts "An Error occured: #{response_hash[:purge_request_response][:return][:result_msg]}"
            exit 1
          else
            plugin_puts "Purge successful!"
          end
        end
      end
    end
  end
end