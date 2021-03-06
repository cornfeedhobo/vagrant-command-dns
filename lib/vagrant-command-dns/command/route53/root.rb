require 'optparse'

module VagrantPlugins
  module CommandDns
    module Command
      module Route53
        class Root < Vagrant.plugin('2', :command)

          def self.synopsis
            'manage route53 dns records'
          end

          def initialize(argv, env)
            super

            @main_args, @sub_command, @sub_args = split_main_and_subcommand(argv)

            @subcommands = Vagrant::Registry.new

            @subcommands.register(:create) do
              require_relative 'create'
              Command::Route53::Create
            end

            @subcommands.register(:destroy) do
              require_relative 'destroy'
              Command::Route53::Destroy
            end
          end

          def execute
            if @main_args.include?('-h') || @main_args.include?('--help')
              return help
            end

            # If we reached this far then we must have a subcommand. If not,
            # then we also just print the help and exit.
            command_class = @subcommands.get(@sub_command.to_sym) if @sub_command
            return help if !command_class || !@sub_command
            @logger.debug("Invoking command class: #{command_class} #{@sub_args.inspect}")

            # Initialize and execute the command class
            command_class.new(@sub_args, @env).execute
          end

          def help
            opts = OptionParser.new do |opts|
              opts.version = VagrantPlugins::CommandDns::VERSION
              opts.banner = 'Usage: vagrant dns route53 <subcommand>'
              opts.separator ''
              opts.separator 'Available subcommands:'

              # Add the available subcommands as separators in order to print them
              # out as well.
              keys = []
              @subcommands.each { |key, value| keys << key.to_s }

              keys.sort.each do |key|
                opts.separator "     #{key}"
              end

              opts.separator ''
              opts.separator 'For help on any individual subcommand run `vagrant dns route53 <subcommand> -h`'
              opts.separator ''
            end

            @env.ui.info(opts.help, prefix: false)
          end

        end
      end
    end
  end
end
