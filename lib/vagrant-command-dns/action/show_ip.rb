module VagrantPlugins
  module CommandDns
    module Action
      class ShowIP

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_command_dns::action::show_ip')
        end

        def call(env)
          if env[:record_map]
            ip = env[:record_map].values[0]
            env[:ui].info("#{ip}")
          end

          @app.call(env)
        end

      end
    end
  end
end
