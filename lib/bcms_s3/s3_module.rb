require 'right_aws'
module Cms
  module S3
    class << self
      attr_accessor :enabled
      attr_accessor :heroku_caching
      attr_accessor :www_domain_prefix
      attr_accessor :options
    end
    module AttachmentsController
      def self.included(controller_class)
        controller_class.alias_method_chain :show, :s3
      end
      
      def show_with_s3
        @attachment = ::Attachment.find(params[:id])
        @attachment = @attachment.as_of_version(params[:version]) if params[:version]
        if Cms::S3.enabled
          #get the file off S3
          redirect_to("http://#{Cms::S3.options[:bucket]}.s3.amazonaws.com/#{@attachment.file_location}")
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
    module ContentController
      def self.included(controller_class)
        controller_class.alias_method_chain :render_page_with_caching, :s3
        controller_class.alias_method_chain :try_to_stream_file, :s3
      end
      def render_page_with_caching_with_s3
        render_page
        response.headers['Cache-Control'] = 'public, max-age=300' if Cms::S3.heroku_caching
      end
      def try_to_stream_file_with_s3
        split = @paths.last.to_s.split('.')
        ext  = split.size > 1 ? split.last.to_s.downcase : nil

        #Only try to stream cache file if it has an extension
        unless ext.blank?

          #Check access to file
          @attachment    = ::Attachment.find_live_by_file_path(@path)
          if @attachment
            raise Cms::Errors::AccessDenied unless current_user.able_to_view?(@attachment)

            if Cms::S3.enabled
              #get the file off S3
              redirect_to("http://#{Cms::S3.options[:bucket]}.s3.amazonaws.com/#{@attachment.file_location}")
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
    module Attachment
      def self.included(model_class)
        model_class.alias_method_chain :set_file_location, :s3
        model_class.alias_method_chain :write_temp_file_to_storage_location, :s3
      end
      def set_file_location_with_s3
        unless temp_file.blank? 
          prefix = temp_file.original_filename.sub(/\..+$/,'') 
          if temp_file.original_filename =~ /.+(\..+)$/ 
            suffix = $1 
          else 
            suffix = "" 
          end 
          new_filename = "#{prefix}-#{ActiveSupport::SecureRandom.hex(4)}#{suffix}" 
          self.file_location = "#{Time.now.strftime("%Y/%m/%d")}/#{new_filename}" 
        end 
      end
      def write_temp_file_to_storage_location_with_s3
        unless temp_file.blank?
          FileUtils.mkdir_p File.dirname(full_file_location)  if !Cms::S3.enabled
          if temp_file.local_path

            if Cms::S3.enabled
              s3 = RightAws::S3.new(Cms::S3.options[:access_key_id], Cms::S3.options[:secret_access_key] )
              bucket = s3.bucket(Cms::S3.options[:bucket], true, 'public-read')
              key = RightAws::S3::Key.create(bucket, file_location)
              key.put(temp_file.read,'public-read', {"Content-Type" => file_type})
            else
              FileUtils.copy temp_file.local_path, full_file_location
            end
          else
            open(full_file_location, 'w') {|f| f << temp_file.read }
          end

          if Cms.attachment_file_permission  && !Cms::S3.enabled
            FileUtils.chmod Cms.attachment_file_permission, full_file_location
          end
        end
      end
    end
    module ApplicationController
      def self.included(controller_class)
        controller_class.alias_method_chain :url_without_cms_domain_prefix, :www
      end
      def url_without_cms_domain_prefix_with_www
        if Cms::S3.www_domain_prefix
          request.url.sub(/#{cms_domain_prefix}\./,'www.')
        else
          request.url.sub(/#{cms_domain_prefix}\./,'')
        end
      end
    end
  end
end

Cms::AttachmentsController.send(:include, Cms::S3::AttachmentsController)
Cms::ContentController.send(:include, Cms::S3::ContentController)
Attachment.send(:include, Cms::S3::Attachment)
Cms::ApplicationController.send(:include, Cms::S3::ApplicationController)
# ensure S3 storage disabled by default
Cms::S3.enabled = false if Cms::S3.enabled.nil?
# ensure heroku caching disabled by default
Cms::S3.heroku_caching = false if Cms::S3.heroku_caching.nil?
# function to set domain prefix without url to 'www' is disabled by default
Cms::S3.www_domain_prefix = false if Cms::S3.www_domain_prefix.nil?
# load s3 options if s3.yml exists
if File.exists?("#{RAILS_ROOT}/config/s3.yml")
  yaml_string = IO.read("#{RAILS_ROOT}/config/s3.yml")
  Cms::S3.options =  YAML::load(ERB.new(yaml_string).result)
  Cms::S3.options.symbolize_keys!
end
