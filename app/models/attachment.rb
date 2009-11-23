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

        if Cms.file_storage_on_s3
          credentials = parse_credentials(Cms.s3_options[:s3_credentials])
          debugger
          s3 = RightAws::S3.new(credentials[:access_key_id], credentials[:secret_access_key] )
          bucket = s3.bucket(Cms.s3_options[:s3_bucket], true, 'public-read')
          key = RightAws::S3::Key.create(bucket, file_location)
          key.put(temp_file.read,'public-read', {"Content-Type" => file_type})
        else
          FileUtils.copy temp_file.local_path, full_file_location
        end
      else
        open(full_file_location, 'w') {|f| f << temp_file.read }
      end

      if Cms.attachment_file_permission  && !Cms.file_storage_on_s3
        FileUtils.chmod Cms.attachment_file_permission, full_file_location
      end
    end
  end
  def parse_credentials creds
    creds = find_credentials(creds).stringify_keys
    (creds[RAILS_ENV] || creds).symbolize_keys
  end
  def find_credentials creds
    case creds
      when File
        YAML.load_file(creds.path)
      when String
        YAML.load_file(creds)
      when Hash
        creds
      else
        raise ArgumentError, "Credentials are not a path, file, or hash."
      end
  end

  private :find_credentials 


end