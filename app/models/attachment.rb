class Attachment < ActiveRecord::Base
  def set_file_location 
      unless temp_file.blank? 
        prefix = temp_file.original_filename.sub(/\..+$/,'') 
        if temp_file.original_filename =~ /.+(\..+)$/ 
          suffix = $1 
        else 
          suffix = "" 
        end 
        new_filename = "#{prefix}-#{SecureRandom.hex(8)}#{suffix}") 
        self.file_location = "#{Time.now.strftime("%Y/%m/%d")}/#{new_filename}" 
      end 
  end
  def write_temp_file_to_storage_location
    unless temp_file.blank?
      FileUtils.mkdir_p File.dirname(full_file_location)  if !Cms.file_storage_on_s3
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
        raise ArgumentError, "OPptions are not a path, file, or hash."
      end
  end

  private :find_s3_options 


end