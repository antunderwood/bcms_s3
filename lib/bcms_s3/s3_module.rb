require 'right_aws'
module Cms
  module S3
    module Module
      class << self
        attr_accessor :enabled
        attr_accessor :heroku_caching
        attr_accessor :options
      end
      module ContentController
        def self.included(controller_class)
          controller_class.send(:include, InstanceMethods)
          controller_class.alias_method_chain :render_page_with_caching, :s3
          controller_class.alias_method_chain :try_to_stream_file, :s3
        end
        # Each instance of the controller will gain these methods.
        module InstanceMethods
          def render_page_with_caching_with_s3
            render_page
            response.headers['Cache-Control'] = 'public, max-age=300' if Cms::S3::Module.heroku_caching
          end
          def try_to_stream_file_with_s3
            split = @paths.last.to_s.split('.')
            ext  = split.size > 1 ? split.last.to_s.downcase : nil

            #Only try to stream cache file if it has an extension
            unless ext.blank?

              #Check access to file
              @attachment    = Attachment.find_live_by_file_path(@path)
              if @attachment
                raise Cms::Errors::AccessDenied unless current_user.able_to_view?(@attachment)

                if Cms::S3::Module.enabled
                  #get the file off S3
                  redirect_to("http://#{Cms::S3::Module.options[:s3_bucket]}.s3.amazonaws.com/#{@attachment.file_location}")

                else
                  #Construct a path to where this file would be if it were cached
                  @file = @attachment.full_file_location

                  #Stream the file if it exists
                  if @path != "/" && File.exists?(@file)
                    send_file(@file, 
                    :filename    => @attachment.file_name,
                    :type        => @attachment.file_type,
                    :disposition => "inline"
                    )
                  end
                end
              end
            end
          end
        end
      end
      module Attachment
        def self.included(model_class)
          model_class.send(:include, InstanceMethods)
          model_class.alias_method_chain :set_file_location, :s3
          model_class.alias_method_chain :write_temp_file_to_storage_location, :s3
        end
        # Each instance of the controller will gain these methods.
        module InstanceMethods
          def set_file_location_with_s3
              unless temp_file.blank? 
                prefix = temp_file.original_filename.sub(/\..+$/,'') 
                if temp_file.original_filename =~ /.+(\..+)$/ 
                  suffix = $1 
                else 
                  suffix = "" 
                end 
                new_filename = "#{prefix}-#{ActiveSupport::SecureRandom.hex(8)}#{suffix}" 
                self.file_location = "#{Time.now.strftime("%Y/%m/%d")}/#{new_filename}" 
              end 
          end
          def write_temp_file_to_storage_location_with_s3
            unless temp_file.blank?
              FileUtils.mkdir_p File.dirname(full_file_location)  if !Cms::S3::Module.enabled
              if temp_file.local_path

                if Cms::S3::Module.enabled
                  s3_config = parse_s3_options("#{RAILS_ROOT}/config/s3.yml")
                  debugger
                  s3 = RightAws::S3.new(s3_config[:access_key_id], s3_config[:secret_access_key] )
                  bucket = s3.bucket(s3_config[:bucket], true, 'public-read')
                  key = RightAws::S3::Key.create(bucket, file_location)
                  key.put(temp_file.read,'public-read', {"Content-Type" => file_type})
                else
                  FileUtils.copy temp_file.local_path, full_file_location
                end
              else
                open(full_file_location, 'w') {|f| f << temp_file.read }
              end

              if Cms.attachment_file_permission  && !Cms::S3::Module.enabled
                FileUtils.chmod Cms.attachment_file_permission, full_file_location
              end
            end
          end
          def parse_s3_options options
            s3_config = find_s3_options(options).stringify_keys
            (s3_config[RAILS_ENV] || s3_config).symbolize_keys
          end
          def find_s3_options options
            case options
              when File
                YAML.load_file(options.path)
              when String
                YAML.load_file(options)
              when Hash
                options
              else
                raise ArgumentError, "Options are not a path, file, or hash."
              end
          end

          private :find_s3_options
        end
      end
    end
  end
end
Cms::ContentController.send(:include, Cms::S3::Module::ContentController)
Attachment.send(:include, Cms::S3::Module::Attachment)
# ensure S3 storage disabled by default
Cms::S3::Module.enabled = false if Cms::S3::Module.enabled.nil?
# ensure heroku caching disabled by default
Cms::S3::Module.heroku_caching = false if Cms::S3::Module.heroku_caching.nil?