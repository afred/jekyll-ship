require 'active_support/core_ext/hash/keys'
require 'jekyll/command'
require 'jekyll/ship/services/github'
require 'jekyll/ship/services/s3'
require 'jekyll/ship/errors'

module Jekyll
  module Commands
    class Ship < Jekyll::Command
      class << self
        def init_with_program(prog)
          prog.command(:ship) do |c|
            c.syntax "ship <service> [options]"
            c.description "Builds the site and ships it somewhere.\n\n" \
                          "Configuration options can be set in _config.yml under\n\n" \
                          "  ship:\n" \
                          "    # Default optons for all services\n" \
                          "    all:\n" \
                          "      <option>: <value>\n" \
                          "    # Options for specific service, e.g. github\n" \
                          "    github:\n" \
                          "      <option>: <value>"

            c.option 'ignore_remote', '--ignore-remote', 'Ignores whether you current banch is curently in sync with the upstream branch'
            c.option 'ignore_unstaged', '--ignore-unstaged', 'Ignores whether you currently have unstaged changes'
            c.option 'ignore_untracked', '--ignore-untracked', 'Ignores whether you currently have untracked files'
            c.option 'baseurl', '--baseurl URL', 'Serve the website from the given base URL'

            # GitHub subcommand
            c.command(:github) do |subcmd|
              subcmd.syntax "github [-u,--user USER] [-r,--repo REPOSITORY] [-b,--branch BRANCH]"
              subcmd.description "Builds the site and ships it to Github to be served by GitHub Pages."
              subcmd.option 'user', '-u', '--user USER', 'GitHub user or organization name.'
              subcmd.option 'repository', '-r', '--repo REPOSITORY', 'The name of the GitHub repository.'
              subcmd.option 'branch', '-b', '--branch BRANCH', 'The name of the branch the generated site will be pushed to.'

              subcmd.action do |_args, options|
                options = options.symbolize_keys
                Jekyll::Ship::Services::Github.new(options).ship
              end
            end

            # S3 subcommand
            c.command(:s3) do |subcmd|
              subcmd.syntax "s3 [--bucket BUCKET]"
              subcmd.description "Builds the site and ships it to Amazon Web Services S3."
              subcmd.option 'bucket', '--bucket BUCKET', 'S3 bucket name set up to serve static websites.'

              subcmd.action do |_args, options|
                options = options.symbolize_keys
                Jekyll::Ship::Services::S3.new(options).ship
              end
            end
          end
        end
      end
    end
  end
end
