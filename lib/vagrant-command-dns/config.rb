module VagrantPlugins
  module CommandDns
    class Config < Vagrant.plugin('2', :config)

      # List of VM aliases in FQDN format
      #
      # @return [Array<String>]
      attr_accessor :aliases

      ### Host Settings

      # List of disallowed aliases in FQDN format
      #
      # @return [Array<String>]
      attr_accessor :host_skip_aliases

      ### AWS Route53 Settings

      # List of disallowed aliases in FQDN format
      #
      # @return [Array<String>]
      attr_accessor :route53_skip_aliases

      # The version of the AWS api to use
      #
      # @return [String]
      attr_accessor :route53_version

      # The access key ID for accessing AWS
      #
      # @return [String]
      attr_accessor :route53_access_key_id

      # The secret access key for accessing AWS
      #
      # @return [String]
      attr_accessor :route53_secret_access_key

      # The token associated with the key for accessing AWS
      #
      # @return [String]
      attr_accessor :route53_session_token

      # The Route53 Zone ID
      #
      # @return [String]
      attr_accessor :route53_zone_id

      attr_accessor :__skip

      def initialize
        @aliases                   = UNSET_VALUE

        @host_skip_aliases         = UNSET_VALUE

        @route53_skip_aliases      = UNSET_VALUE
        @route53_version           = UNSET_VALUE
        @route53_access_key_id     = UNSET_VALUE
        @route53_secret_access_key = UNSET_VALUE
        @route53_session_token     = UNSET_VALUE
        @route53_zone_id           = UNSET_VALUE

        # Internal
        @__skip = false
      end

      def finalize!
        @aliases      = [] if @aliases      == UNSET_VALUE

        @host_skip_aliases = [] if @host_skip_aliases == UNSET_VALUE

        @route53_skip_aliases = [] if @route53_skip_aliases == UNSET_VALUE

        @route53_version = nil if @route53_version == UNSET_VALUE
        @route53_zone_id = nil if @route53_zone_id == UNSET_VALUE

        # Try to get access keys from standard AWS environment variables; they
        # will default to nil if the environment variables are not present.
        @route53_access_key_id     = ENV['AWS_ACCESS_KEY']    if @route53_access_key_id     == UNSET_VALUE
        @route53_secret_access_key = ENV['AWS_SECRET_KEY']    if @route53_secret_access_key == UNSET_VALUE
        @route53_session_token     = ENV['AWS_SESSION_TOKEN'] if @route53_session_token     == UNSET_VALUE
      end

      def validate(machine)
        errors = _detected_errors

        errors << I18n.t('vagrant_command_dns.config.common.aliases_list_required') unless @aliases.kind_of? Array

        errors << I18n.t('vagrant_command_dns.config.host.skip_aliases_list_required') unless @host_skip_aliases.kind_of? Array

        if machine.provider_name == :aws
          aws_config = machine.provider_config
          # If these values are still not set and the AWS provider is being used, borrow it's config values
          @route53_version           = aws_config.version           if @route53_version           == nil
          @route53_access_key_id     = aws_config.access_key_id     if @route53_access_key_id     == nil
          @route53_secret_access_key = aws_config.secret_access_key if @route53_secret_access_key == nil
          @route53_session_token     = aws_config.session_token     if @route53_session_token     == nil
        end

        errors << I18n.t('vagrant_command_dns.config.route53.skip_aliases_list_required') unless @route53_skip_aliases.kind_of? Array

        { :DNS => errors }
      end

    end
  end
end
