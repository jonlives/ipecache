module Ipecache
  module Plugins
    class Plugin
      # This is the name of the plugin. It must correspond to the name in the yaml configuration
      # file in order to load this plugin. If an attribute is passed in, the name is set to that
      # given value. Otherwise, the name is returned.
      def self.name(name = nil)
        if name.nil?
          class_variable_get(:@@name)
        else
          class_variable_set(:@@name, name)
        end
      end

      # This is a convenience method for defining multiple hooks in a single call.
      def self.hooks(*the_hooks)
        [the_hooks].flatten.each{ |the_hook| hook(the_hook) }
      end

      # When defining a hook, we define a method on the instance that corresponds to that
      # hook. That will be fired when the hook is fired.
      def self.hook(the_hook)
        self.send(:define_method, the_hook.to_sym) do
          perform
        end
      end

      def initialize(options = {})
        @options = {
            :payload => {}
        }.merge(options)
      end

      def enabled?
        !(config.nil? || config.enabled == false)
      end

      def urls
        @options[:urls]
      end

      def log_file
        @options[:log_file]
      end

      def continue_on_error
        @options[:continue_on_error]
      end

      def name
        self.class.to_s
      end

      def plugin_puts(message)
        puts "#{name}: #{message}"
      end

      def plugin_puts_error(url,message)
        if log_file
          File.open(log_file, 'a') { |file| file.write("#{Time.now.getutc} #{url} #{name}: #{message}\n") }
        end
        puts "#{url} #{name}: #{message}"
      end

      private
      def config
        @options[:config].plugins.send(self.class.name.to_sym) unless @options[:config].nil? || @options[:config].plugins.nil?
      end

      # Wrapper method around require that attempts to include the associated file. If it does not exist
      # or cannot be loaded, an nice error is produced instead of blowing up.
      def safe_require(file)
        begin
          require file
        rescue LoadError
          raise "You are using a plugin for ipecache that requires #{file}, but you have not installed it. Please either run \"gem install #{file}\", add #{file} to your Gemfile or remove the plugin from your configuration."
        end
      end
    end
  end
end
