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
                raise Errors::MachineState, state: 'running'
              end
            end

            # read the file into memory to save reading it for each alias
            lines = []
            File.open('/etc/hosts', 'r') do |file|
              file.each_line do |line|
                lines.push(line.chomp)
              end
            end

            destroyed = {}
            env[:record_map].each do |hostname, ip|
              if env[:machine].config.dns.__skip
                record_pattern = Regexp.new('^\s*[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\s+' + hostname)
              else
                record_pattern = Regexp.new('^\s*' + ip + '\s+' + hostname)
              end

              lines.each do |line|
                if line.match(/#{record_pattern}/)
                  lines.delete(line)
                  destroyed[hostname] = ip
                end
              end
            end

            if destroyed.length > 0
              content = lines.join("\n").strip
              if system("sudo sh -c 'echo \"#{content}\" > /etc/hosts'")
                destroyed.each do |hostname, ip|
                  env[:ui].info(I18n.t('vagrant_command_dns.command.host.destroy_success', hostname: hostname))
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
