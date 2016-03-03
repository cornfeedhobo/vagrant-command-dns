require 'pathname'

module VagrantPlugins
  module CommandDns
    module Action
      module Route53

        def self.route53_create
          Vagrant::Action::Builder.new.tap do |b|
            b.use Action::ConfigValidate
            b.use Action::GetIP
            b.use Route53::Connect
            b.use Route53::Create
          end
        end

        def self.route53_destroy
          Vagrant::Action::Builder.new.tap do |b|
            b.use Action::ConfigValidate
            b.use Action::GetIP
            b.use Route53::Connect
            b.use Route53::Destroy
          end
        end

        route53_root = Pathname.new(File.expand_path('../route53', __FILE__))
        autoload :Connect, route53_root.join('connect')
        autoload :Create, route53_root.join('create')
        autoload :Destroy, route53_root.join('destroy')

      end
    end
  end
end
