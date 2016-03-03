require 'log4r'
require 'excon'

module VagrantPlugins
  module CommandDns
    module Action
      module Route53
        class Create

          def initialize(app, env)
            @app    = app
            @logger = Log4r::Logger.new('vagrant_command_dns::action::route53::create')
          end

          def call(env)
            if env[:machine].state.id != :running
              raise Errors::MachineStateError, state: 'running'
            end

            env[:record_map].each do |hostname, ip|
              @logger.info("Checking for existing '#{hostname}' Route53 record...")

              record_name = hostname + '.' unless hostname.end_with?('.')

              begin
                zone = env[:route53].zones.get(env[:machine].config.dns.route53_zone_id)
                record = zone.records.get(record_name)
              rescue Excon::Errors::SocketError
                env[:ui].error(I18n.t('vagrant_command_dns.command.route53.fog_error',
                                      message: 'Unable to reach AWS. Are you connected to the internet?'))
              rescue Fog::DNS::AWS::Error => err
                env[:ui].error(I18n.t('vagrant_command_dns.command.route53.fog_error',
                                      message: err.message))
              end

              if record.nil? || record.attributes[:name] != record_name
                @logger.info('Creating Route53 record...')
                begin
                  new_record = zone.records.new({
                    :value => ip,
                    :name  => record_name,
                    :type  => 'A',
                    :ttl   => '60'
                  })
                  new_record.save
                rescue Fog::DNS::AWS::Error => err
                  env[:ui].error(I18n.t('vagrant_command_dns.command.route53.fog_error',
                                        message: err.message))
                end
                env[:ui].info(I18n.t('vagrant_command_dns.command.route53.create_success',
                                     ip: ip, hostname: hostname))

              elsif record.attributes[:value][0] == ip
                env[:ui].info(I18n.t('vagrant_command_dns.command.route53.create_exists_match',
                                     ip: ip, hostname: hostname))

              elsif record.attributes[:value][0] != ip
                env[:ui].warn(I18n.t('vagrant_command_dns.command.route53.create_exists_conflict',
                                     ip: ip, hostname: hostname))

              end
            end

            @app.call(env)
          end

        end
      end
    end
  end
end
