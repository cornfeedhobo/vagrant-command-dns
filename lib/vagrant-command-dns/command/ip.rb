require 'optparse'

module VagrantPlugins
  module CommandDns
    module Command
      class IP < Vagrant.plugin('2', :command)

        def execute
          options = {}

          opts = OptionParser.new do |o|
            o.banner = 'Usage: vagrant dns ip'
            o.separator ''
            o.separator 'Additional documentation can be found on the plugin homepage'
            o.separator ''
          end

          argv = parse_options(opts)
          return if !argv

          with_target_vms(argv) do |machine|
            @env.action_runner.run(Action.show_ip, {
              machine: machine,
              ui: Vagrant::UI::Prefixed.new(@env.ui, 'dns'),
            })
          end

          0
        end

      end
    end
  end
end