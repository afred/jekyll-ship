require 'jekyll/ship/services/git'

module Jekyll
  module Ship
    module Services
      class Github < Git

        required_options :user, :repository

        def initialize(options = {})
          options[:repository_url] = "git@github.com:#{options.fetch(:user)}/#{options.fetch(:repository)}.git"
          super options
        end
      end
    end
  end
end
