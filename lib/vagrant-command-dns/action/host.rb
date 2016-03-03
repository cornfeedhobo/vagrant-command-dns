require 'pathname'

module VagrantPlugins
  module CommandDns
    module Action
      module Host

        def self.host_create
          Vagrant::Action::Builder.new.tap do |b|
            b.use Action::ConfigValidate
            b.use Action::GetIP
            b.use Host::Create
          end
        end

        def self.host_destroy
          Vagrant::Action::Builder.new.tap do |b|
            b.use Action::ConfigValidate
            b.use Action::GetIP
            b.use Host::Destroy
          end
        end

        host_root = Pathname.new(File.expand_path('../host', __FILE__))
        autoload :Create, host_root.join('create')
        autoload :Destroy, host_root.join('destroy')

      end
    end
  end
end
