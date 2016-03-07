require 'log4r'


module VagrantPlugins
  module CommandDns
    module Action
      module Route53
        class Destroy

          def initialize(app, env)
            @app    = app
            @logger = Log4r::Logger.new('vagrant_command_dns::action::route53::destroy')
          end

          def call(env)
            unless env[:machine].config.dns.__skip
              if env[:machine].state.id != :running
                raise Errors::MachineState, state: 'running'
              end
            end

            env[:record_map].each do |hostname, ip|
              @logger.info("Checking for existing '#{hostname}' Route53 record...")

              record_name = hostname + '.' unless hostname.end_with?('.')

              begin
                zone = env[:route53].zones.get(env[:machine].config.dns.route53_zone_id)
                record = zone.records.get(record_name)
              rescue Fog::DNS::AWS::Error => err
                env[:ui].error(I18n.t('vagrant_command_dns.command.route53.fog_error',
                                      message: err.message))
              end

              if !record.nil? && record.attributes[:name] == record_name
                if env[:machine].config.dns.__skip == true || record.attributes[:value][0] == ip
                  @logger.info("Deleting Route53 record for '#{hostname}'...")
                  begin
                    record.destroy
                  rescue Fog::DNS::AWS::Error => err
                    env[:ui].error(I18n.t('vagrant_command_dns.command.route53.fog_error',
                                          message: err.message))
                  end
                  env[:ui].info(I18n.t('vagrant_command_dns.command.route53.destroy_success',
                                       ip: ip, hostname: hostname))

                elsif record.attributes[:value][0] != ip
                  env[:ui].warn(I18n.t('vagrant_command_dns.command.route53.destroy_conflict',
                                       hostname: hostname,
                                       expected: ip,
                                       got: record.attributes[:value][0]))
                else
                  raise Errors::VagrantCommandDnsError
                end
              else
                env[:ui].info(I18n.t('vagrant_command_dns.command.route53.destroy_not_found',
                                     hostname: hostname))
              end

            end

            @app.call(env)
          end

        end
      end
    end
  end
end
