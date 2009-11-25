require 'bcms_s3/routes'
module Cms
  module S3
    module Module
      class << self
        attr_accessor :enabled
        attr_accessor :heroku_caching
        attr_accessor :options
      end
    end
  end
end
# ensure S3 storage disabled by default
Cms::S3::Module.enabled = false if Cms::S3::Module.enabled.nil?
# ensure heroku caching disabled by default
Cms::S3::Module.heroku_caching = false if Cms::S3::Module.heroku_caching.nil?