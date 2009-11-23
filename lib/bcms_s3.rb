require 'bcms_s3/routes'
module Cms
  class << self
	attr_accessor :file_storage_on_s3
	attr_accessor :s3_options


	# This is called after the environment is ready
	def init
	  Cms.file_storage_on_s3 if Cms.file_storage_on_s3.nil?
	end
  end
end