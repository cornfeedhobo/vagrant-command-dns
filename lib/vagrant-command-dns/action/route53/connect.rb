require 'fog'
require 'log4r'
require 'vagrant/util/ssh'

module VagrantPlugins
  module CommandDns
    module Action
      module Route53
        # This action connects to AWS, verifies credentials work, and
        # puts the AWS connection object into the `:aws_compute` key
        # in the environment.
        class Connect

          # For quick access to the `SSH` class.
          include Vagrant::Util

          def initialize(app, env)
            @app    = app
            @logger = Log4r::Logger.new('vagrant_command_dns::action::route53::connect')
          end

          def call(env)
            # Build the fog config
            fog_config = {
                :provider              => :aws,
                :aws_access_key_id     => env[:machine].config.dns.route53_access_key_id,
                :aws_secret_access_key => env[:machine].config.dns.route53_secret_access_key,
                :aws_session_token     => env[:machine].config.dns.route53_session_token
            }
            fog_config[:version]  = env[:machine].config.dns.route53_version if env[:machine].config.dns.route53_version

            @logger.info('Connecting to AWS...')
            env[:route53] = Fog::DNS.new(fog_config)

            @app.call(env)
          end

        end
      end
    end
  end
end
