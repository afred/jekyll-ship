require 'jekyll/ship/services/git'
require 'aws-sdk-s3'

module Jekyll
  module Ship
    module Services
      class S3 < Base
        required_options :bucket

        def this_process_will
          "build the site and upload it to S3 bucket '#{options[:bucket]}'. " \
          "The bucket must be configured to host static websites, and you" \
          "must have permissions to upload to it from your computer."
        end

        def process
          Dir.mktmpdir do |tmp_dir|
            run_command build_command(destination: tmp_dir)
            Dir.glob("#{tmp_dir}/**/*").each do |entry|
              if File.file? entry
                rel_path = entry.sub("#{tmp_dir}/", '')
                logger.info "Uploading #{rel_path} to bucket #{options[:bucket]}"
                obj = s3.bucket(options[:bucket]).object(rel_path)
                obj.upload_file(entry, acl: 'public-read')
              end
            end
          end
        end

        def default_options
          { region: 'us-east-1' }
        end

        protected

          def s3
            @s3 ||= Aws::S3::Resource.new(region: options[:region])
          end
      end
    end
  end
end
