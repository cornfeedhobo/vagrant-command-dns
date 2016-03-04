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
            env[:record_map].each do |h, ip|
              env[:ui].info "#{h} #{ip}"
            end
          end

          @app.call(env)
        end

      end
    end
  end
end
