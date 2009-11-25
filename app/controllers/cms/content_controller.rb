class Cms::ContentController < Cms::ApplicationController
     def render_page_with_caching
       render_page
       response.headers['Cache-Control'] = 'public, max-age=300' if Cms::S3::Module.heroku_caching
     end
  def try_to_stream_file
    split            = @paths.last.to_s.split('.')
    ext              = split.size > 1 ? split.last.to_s.downcase : nil

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
