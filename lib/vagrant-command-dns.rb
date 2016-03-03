require 'pathname'
require 'vagrant-command-dns/version'
require 'vagrant-command-dns/plugin'

module VagrantPlugins
  module CommandDns

    lib_path = Pathname.new(File.expand_path('../vagrant-command-dns', __FILE__))
    autoload :Action, lib_path.join('action')
    autoload :Errors, lib_path.join('errors')

    # This returns the path to the source of this plugin.
    #
    # @return [Pathname]
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end

  end
end
