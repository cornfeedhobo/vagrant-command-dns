require 'vagrant/action/builder'

module VagrantPlugins
  module CommandDns
    module Action

      # Include the built-in modules so we can use them as top-level things.
      include Vagrant::Action::Builtin

      def self.show_ip
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use GetIP
          b.use ShowIP
        end
      end

      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :GetIP, action_root.join('get_ip')
      autoload :ShowIP, action_root.join('show_ip')
      autoload :Host, action_root.join('host')
      autoload :Route53, action_root.join('route53')

    end
  end
end
