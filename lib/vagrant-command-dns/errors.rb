module VagrantPlugins
  module CommandDns
    module Errors

      class VagrantCommandDnsError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_command_dns.errors')
      end

      class MachineStateError < VagrantCommandDnsError
        error_key(:machine_state_error)
      end

      class UnsupportedProviderError < VagrantCommandDnsError
        error_key(:unsupported_provider_error)
      end

      class InvalidAddressError < VagrantCommandDnsError
        error_key(:invalid_address_error)
      end

      class FogError < VagrantCommandDnsError
        error_key(:fog_error)
      end

      class EditLocalHostsError < VagrantCommandDnsError
        error_key(:edit_local_hosts_error)
      end

    end
  end
end
