require 'tmpdir'
require 'jekyll/ship/services/base'

module Jekyll
  module Ship
    module Services
      class Git < Base

        def this_process_will
          "build the site into a temporary directory and commit the results to #{options[:repository_url]} on branch #{options[:branch]}."
        end

        def process
          Dir.mktmpdir do |tmp_dir|
            run_command "git clone --branch #{options[:branch]} --single-branch -- #{options[:repository_url]} #{tmp_dir}"
            run_command build_command(destination: tmp_dir)
            Dir.chdir tmp_dir do
              logger.info "(within #{tmp_dir})"
              run_command "git add ."
              run_command "git commit -m \"#{commit_msg}\""
              run_command "git push #{options[:repository_url]} #{options[:branch]}"
            end
          end
        end

        protected

          def commit_msg
            "Published: #{Time.now} " \
            "\nAuthor: #{git_user}" \
            "\nSummary: #{git_diff_shortstat}"
          end

          ###
          # Git shortcuts.
          ###
          def git_user; `git config user.name`; end
          def git_diff_shortstat; `git diff --shortstat HEAD~1..HEAD`; end
      end
    end
  end
end
