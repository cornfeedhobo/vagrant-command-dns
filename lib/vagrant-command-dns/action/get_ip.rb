require 'ipaddr'

module VagrantPlugins
  module CommandDns
    module Action
      class GetIP

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_command_dns::action::get_ip')
        end

        def call(env)
          if !env[:machine].config.dns.__skip
            if env[:machine].state.id != :running
              raise Errors::MachineStateError
            end

            ip = nil

            case env[:machine].provider_name
              when :virtualbox
                env[:machine].config.vm.networks.each do |network|
                  key, options = network[0], network[1]
                  if key == :private_network or key == :public_network
                    if options[:dns] != 'skip'
                      case key
                        when :private_network
                          cmd = "vagrant ssh -c \"ip -4 addr show \\$(ip -4 route | tail -n1 | awk '{print \\$3}') | grep -oP '(?<=inet\\s)\\d+(\\.\\d+){3}'\" 2>/dev/null"
                        when :public_network
                          cmd = "vagrant ssh -c \"ip -4 addr show \\$(ip -4 route | head -n2 | tail -n1 | awk '{print \\$5}') | grep -oP '(?<=inet\\s)\\d+(\\.\\d+){3}'\" 2>/dev/null"
                      end
                      begin
                        ip = IPAddr.new(`#{cmd}`.chomp)
                      rescue IPAddr::InvalidAddressError
                        raise Errors::InvalidAddressError
                      end
                    else
                      env[:ui].info(I18n.t('vagrant_command_dns.config.network_skip'))
                    end
                  end
                end
              else
                raise Errors::UnsupportedProviderError
            end

            unless ip.nil?
              host_names = [env[:machine].config.vm.hostname]
              env[:machine].config.dns.aliases.each do |a|
                host_names.push(a)
              end

              record_map = {}
              host_names.each do |h|
                record_map[h] = ip.to_string
              end

              env[:record_map] = record_map
            end

          else
            host_names = [env[:machine].config.vm.hostname]
            env[:machine].config.dns.aliases.each do |a|
              host_names.push(a)
            end

            record_map = {}
            host_names.each do |h|
              record_map[h] = ip
            end

              env[:record_map] = record_map
          end

          @app.call(env)
        end

      end
    end
  end
end
