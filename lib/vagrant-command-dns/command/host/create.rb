require 'optparse'

module VagrantPlugins
  module CommandDns
    module Command
      module Host
        class Create < Vagrant.plugin('2', :command)

          def execute
            opts = OptionParser.new do |o|
              o.banner = 'Usage: vagrant dns host create'
              o.separator ''
              o.separator 'Additional documentation can be found on the plugin homepage'
              o.separator ''
            end

            argv = parse_options(opts)
            return if !argv

            with_target_vms(argv) do |machine|
              @env.action_runner.run(Action::Host.host_create, {
                  machine: machine,
                  ui: Vagrant::UI::Prefixed.new(@env.ui, 'dns host'),
              })
            end

            0
          end

        end
      end
    end
  end
end
