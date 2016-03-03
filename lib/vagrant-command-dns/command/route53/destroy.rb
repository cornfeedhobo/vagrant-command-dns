require 'optparse'

module VagrantPlugins
  module CommandDns
    module Command
      module Route53
        class Destroy < Vagrant.plugin('2', :command)

          def execute
            options = {}
            options[:skip] = false

            opts = OptionParser.new do |o|
              o.banner = 'Usage: vagrant dns route53 destroy [options]'
              o.separator ''
              o.separator 'Options:'
              o.separator ''

              o.on('-s', '--skip', 'Skip ip check before record destruction. Use with extreme caution.') do |skip|
                options[:skip] = skip
              end

              o.separator ''
              o.separator 'Additional documentation can be found on the plugin homepage'
              o.separator ''
            end

            argv = parse_options(opts)
            return if !argv

            with_target_vms(argv) do |machine|
              machine.config.dns.__skip = options[:skip] if options[:skip]
              @env.action_runner.run(Action::Route53.route53_destroy, {
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
