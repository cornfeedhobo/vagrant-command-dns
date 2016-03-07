module VagrantPlugins
  module CommandDns
    module Errors

      class VagrantCommandDnsError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_command_dns.errors')
      end

      class ConfigInvalid < VagrantCommandDnsError
        error_key(:config_invalid)
      end

      class MachineState < VagrantCommandDnsError
        error_key(:machine_state)
      end

      class UnsupportedProvider < VagrantCommandDnsError
        error_key(:unsupported_provider)
      end

      class InvalidAddress < VagrantCommandDnsError
        error_key(:invalid_address)
      end

      class NoNetwork < VagrantCommandDnsError
        error_key(:no_network)
      end

    end
  end
end
