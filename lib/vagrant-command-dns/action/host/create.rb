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
              raise Errors::MachineStateError, state: 'running'
            end

            lines = []
            env[:record_map].each do |hostname, ip|
              loose_pattern = Regexp.new('^\s*[0-9]{1,3}[0-9]{1,3}[0-9]{1,3}[0-9]{1,3}\s+' + hostname)
              precise_pattern = Regexp.new('^\s*' + ip + '\s+' + hostname)
              File.open('/etc/hosts', 'r') do |f|
                f.each_line do |line|
                  if line.match(/#{precise_pattern}/)
                    env[:ui].info(I18n.t('vagrant_command_dns.command.host.create_exists_match',
                                         ip: ip, hostname: hostname))
                    return
                  elsif line.match(/#{loose_pattern}/)
                    env[:ui].info(I18n.t('vagrant_command_dns.command.host.create_exists_conflict'))
                  end
                end
              end
              lines.push("#{ip}    #{hostname}")
            end

            content = lines.join("\n").strip
            unless system("sudo sh -c 'echo \"#{content}\" >> /etc/hosts'")
              env[:ui].error(I18n.t('vagrant_command_dns.command.host.edit_error'))
            end

            @app.call(env)
          end

        end
      end
    end
  end
end
