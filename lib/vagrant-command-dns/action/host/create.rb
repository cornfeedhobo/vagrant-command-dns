require 'log4r'

module VagrantPlugins
  module CommandDns
    module Action
      module Host
        class Create

          def initialize(app, env)
            @app    = app
            @logger = Log4r::Logger.new('vagrant_command_dns::action::host::create')
          end

          def call(env)
            if env[:machine].state.id != :running
              raise Errors::MachineState, state: 'running'
            end

            record_map = env[:record_map]

            File.open('/etc/hosts', 'r') do |file|
              file.each_line do |line|
                env[:record_map].each do |hostname, ip|
                  precise_pattern = Regexp.new('^\s*' + ip + '\s+' + hostname)
                  loose_pattern = Regexp.new('^\s*[0-9]{1,3}[0-9]{1,3}[0-9]{1,3}[0-9]{1,3}\s+' + hostname)
                  if line.match(/#{precise_pattern}/)
                    record_map.delete(hostname)
                    env[:ui].info(I18n.t('vagrant_command_dns.command.host.create_exists_match', ip: ip, hostname: hostname))
                  elsif line.match(/#{loose_pattern}/)
                    env[:ui].info(I18n.t('vagrant_command_dns.command.host.create_exists_conflict'))
                  end
                end
              end
            end

            lines = []
            record_map.each do |hostname, ip|
              if env[:machine].config.dns.host_skip_aliases.include?(hostname)
                env[:ui].info(I18n.t('vagrant_command_dns.command.host.skip_alias', hostname: hostname))
              else
                lines.push("#{ip}    #{hostname}")
              end
            end

            if lines.length > 0
              content = lines.join("\n").strip
              if system("sudo sh -c 'echo \"#{content}\" >> /etc/hosts'")
                record_map.each do |hostname, ip|
                  env[:ui].info(I18n.t('vagrant_command_dns.command.host.create_success', ip: ip, hostname: hostname))
                end
              else
                env[:ui].error(I18n.t('vagrant_command_dns.command.host.edit_error'))
              end
            end

            @app.call(env)
          end

        end
      end
    end
  end
end
