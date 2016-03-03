require 'optparse'

module VagrantPlugins
  module CommandDns
    module Command
      module Route53
        class Create < Vagrant.plugin('2', :command)

          def execute
            opts = OptionParser.new do |o|
              o.banner = 'Usage: vagrant dns route53 create'
              o.separator ''
              o.separator 'Additional documentation can be found on the plugin homepage'
              o.separator ''
            end

            argv = parse_options(opts)
            return if !argv

            with_target_vms(argv) do |machine|
              @env.action_runner.run(Action::Route53.route53_create, {
                  machine: machine,
                  ui: Vagrant::UI::Prefixed.new(@env.ui, 'dns route53'),
              })
            end

            0
          end

        end
      end
    end
  end
end
