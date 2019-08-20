require 'jekyll/ship/abstract_methods'
require 'active_support/core_ext/string/inflections'
require 'yaml'

module Jekyll
  module Ship
    module Services
      class Base
        include AbstractMethods

        attr_reader :options, :logger, :config_file_paths

        abstract :process
        abstract :this_process_will

        def initialize(options={})
          @logger = options.delete(:logger) || Logger.new(STDOUT)
          # Before merging options, pull out any config file paths specified
          # in the 'config' options, as these will be needed to merge options.
          @config_file_paths = options.fetch('config', ['./_config.yml'])
          @options = merge_options(options)
        end

        def ship
          validate_site_is_ready_to_ship!
          logger.info "Site is ready!"
          logger.info "This process will #{this_process_will}"
          process
        end

        protected

          def run_command(command)
            logger.info "Running: #{command}"
            `#{command}`
          end

          def build_command(destination: nil)
            cmd = 'bundle exec jekyll build'
            cmd += " -d #{destination}" if destination
            cmd += " --baseurl #{options[:baseurl]}" if options.key? :baseurl
            cmd
          end


          def validate_site_is_ready_to_ship!
            validate_required_options!
            validate_in_sync_with_remote! unless ignore_remote?
            validate_no_unstaged_changes! unless ignore_unstaged?
            validate_no_untracked_files! unless ignore_untracked?
          end

          def validate_required_options!
            missing_options = self.class.required_options.select { |opt_name| !options.key?(opt_name) }
            raise_missing_required_options(missing_options) unless missing_options.count == 0
          end

          def validate_in_sync_with_remote!
            behind, ahead = `git rev-list --left-right --count origin/master...HEAD`.split(/\s/).map(&:to_i)
            raise_not_in_sync_with_origin_master(ahead, behind) unless ahead == 0 && behind == 0
          end

          def validate_no_unstaged_changes!
            count = `git diff --name-only`.split("\n").count
            raise_unstaged_changes(count) if count > 0
          end

          def validate_no_untracked_files!
            count = `git ls-files . --exclude-standard --others`.split("\n").count
            raise_untracked_files(count) if count > 0
          end

          def ignore_remote?
            truthy? options.fetch(:ignore_remote, false)
          end

          def ignore_unstaged?
            truthy? options.fetch(:ignore_unstaged, false)
          end

          def ignore_untracked?
            truthy? options.fetch(:ignore_untracked, false)
          end

          ###
          # Error handling methods.
          ###
          def raise_missing_required_options(options)
            raise "Missing required option(s): #{Array(options).join(', ')}"
          end

          def raise_not_in_sync_with_origin_master(ahead, behind)
            msg = "This branch is not in sync with the upstream branch.\n" \
                  "You are #{ahead} commit(s) ahead and #{behind} commit(s) " \
                  "behind origin/master. Use --ignore-remote to ship anyway."
            raise msg
          end

          def raise_unstaged_changes(count)
            msg = "You have #{count.to_i} unstaged changes that may affect " \
                  "how the site is built. Use --ignore-unstaged to ship anyway."
            raise msg
          end

          def raise_untracked_files(count)
            msg = "You have #{count.to_i} untracked files that may affect " \
                  "how the site is built. Use --ignore-untracked to ship anyway."
            raise msg
          end

          # truthy is not falsey
          def truthy?(val); !falsey?(val); end

          # falsey is a few things other than false
          def falsey?(val)
            [false, 0, nil, '0'].any? val
          end

          # Delegated to class
          def required_options; self.class.required_options; end
          def default_options; self.class.default_options; end

          # Merges options together in this order (latter overwriting former)
          # 1. The @default_options hash for the class.
          # 2. Default config from YAML config files.
          # 3. Service-specific config from YAML config files.
          # 4. Options that were passed in at runtime.
          # @return [Hash] the fully merged hash of config options
          def merge_options(options)
            sources_of_options = [default_options] + config_from_files + [options]
            sources_of_options.reduce({}) { |merged_result, next_options_hash| merged_result.merge(next_options_hash) }
          end

          # For each config file path, parses the YAML and merges the default
          # config with the service-specific config.
          # @return [Array<Hash>] the parsed YAML from each config file path.
          def config_from_files
            config_file_paths.map do |path|
              all_config = YAML.load_file(path)
              ship_config_defaults = complete_config.fetch('ship', {}).fetch('default', {})
              ship_config_for_service = complete_config.fetch('ship', {}).fetch(config_key, {})
              ship_config_defaults.merge ship_config_for_service
            rescue Errno::ENOENT
              logger.warn "Config file '#{path}' not found, skipping."
              nil
            end.compact
          end

        class << self
          # Get/set the class's required options. The set of required options
          # can be set cumulatively by any class in an object's inheritance chain.
          def required_options(*keys)
            @required_options ||= Set.new
            @required_options.merge Set.new(keys)
          end

          # Get/set the class's default options. The hash of default options
          # can be set cumulatively by an class in an object's inheritance chain.
          def default_options(opts={})
            @default_options ||= {}
            @default_options.merge opts
          end

          # Returns the config key for service, which is the underscored class
          # name of the extended class.
          def config_key
            self.to_s.underscore.to_sym
          end
        end
      end
    end
  end
end
