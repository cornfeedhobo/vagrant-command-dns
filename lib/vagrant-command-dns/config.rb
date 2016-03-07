module VagrantPlugins
  module CommandDns
    class Config < Vagrant.plugin('2', :config)

      # List of VM aliases in FQDN format
      #
      # @return [Array<String>]
      attr_accessor :aliases

      # List of disallowed aliases in FQDN format
      #
      # @return [Array<String>]
      attr_accessor :skip_aliases

      # AWS Route53 Settings

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
        @skip_aliases              = UNSET_VALUE

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
        @skip_aliases = [] if @skip_aliases == UNSET_VALUE

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

        if machine.provider_name == :aws
          aws_config = machine.provider_config
          # If these values are still not set and the AWS provider is being used, borrow it's config values
          @route53_version           = aws_config.version           if @route53_version           == nil
          @route53_access_key_id     = aws_config.access_key_id     if @route53_access_key_id     == nil
          @route53_secret_access_key = aws_config.secret_access_key if @route53_secret_access_key == nil
          @route53_session_token     = aws_config.session_token     if @route53_session_token     == nil
        end

        errors << I18n.t('vagrant_command_dns.config.aliases_list_required') unless @aliases.kind_of? Array
        errors << I18n.t('vagrant_command_dns.config.skip_aliases_list_required') unless @skip_aliases.kind_of? Array

        { 'DNS' => errors }
      end

    end
  end
end
