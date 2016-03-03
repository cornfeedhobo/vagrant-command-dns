begin
  require 'vagrant'
rescue LoadError
  raise 'The Vagrant DNS Plugin must be run within Vagrant'
end

# This is a sanity check to make sure no one is attempting to install this
# into a Vagrant version earlier than it was developed on.
if Vagrant::VERSION < '1.7.4'
  raise 'The Vagrant DNS Plugin is only compatible with Vagrant 1.7.4+'
end

module VagrantPlugins
  module CommandDns
    class Plugin < Vagrant.plugin('2')

      name 'dns command'
      description 'The `dns` command gives you a way to manage DNS records.'

      # This initializes the internationalization strings.
      def self.setup_i18n
        I18n.load_path << File.expand_path('locales/en.yml', CommandDns.source_root)
        I18n.reload!
      end

      # This sets up our log level to be whatever VAGRANT_LOG is.
      def self.setup_logging
        require 'log4r'

        level = nil
        begin
          level = Log4r.const_get(ENV['VAGRANT_LOG'].upcase)
        rescue NameError
          # This means that the logging constant wasn't found,
          # which is fine. We just keep `level` as `nil`. But
          # we tell the user.
          level = nil
        end

        # Some constants, such as "true" resolve to booleans, so the
        # above error checking doesn't catch it. This will check to make
        # sure that the log level is an integer, as Log4r requires.
        level = nil if !level.is_a?(Integer)

        # Set the logging level on all "vagrant" namespaced
        # logs as long as we have a valid level.
        if level
          logger = Log4r::Logger.new('vagrant_command_dns')
          logger.outputters = Log4r::Outputter.stderr
          logger.level = level
          logger = nil
        end
      end

      config 'dns' do
        setup_i18n
        require_relative 'config'
        Config
      end

      command 'dns' do
        setup_logging
        require_relative 'command/root'
        Command::Root
      end

    end
  end
end
