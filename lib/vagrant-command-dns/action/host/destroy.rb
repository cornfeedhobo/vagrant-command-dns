require 'log4r'

module VagrantPlugins
  module CommandDns
    module Action
      module Host
        class Destroy

          def initialize(app, env)
            @app    = app
            @logger = Log4r::Logger.new('vagrant_command_dns::action::host::destroy')
          end

          def call(env)
            unless env[:machine].config.dns.__skip
              if env[:machine].state.id != :running
                raise Errors::MachineStateError, state: 'running'
              end
            end

            lines = []
            env[:record_map].each do |hostname, ip|
              if env[:machine].config.dns.__skip
                record_pattern = Regexp.new('^\s*[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\s+' + hostname)
              else
                record_pattern = Regexp.new('^\s*' + ip + '\s+' + hostname)
              end
              File.open('/etc/hosts', 'r') do |f|
                f.each_line do |line|
                  unless line.match(/#{record_pattern}/)
                    lines.push(line.chomp)
                  end
                end
              end
            end

            content = lines.join("\n").strip
            unless system("sudo sh -c 'echo \"#{content}\" > /etc/hosts'")
              env[:ui].error(I18n.t('vagrant_command_dns.command.host.edit_error'))
            end

            @app.call(env)
          end

        end
      end
    end
  end
end
