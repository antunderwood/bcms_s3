# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'
begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "bcms_s3"
    gem.summary = %Q{This is a browsercms (browsercms.org) module to allow the facility to have attachments stored on Amazon S3. Also there is the option to change caching to suit heroku}
    gem.email = "email2ants@gmail.com"
    gem.homepage = "http://github.com/aunderwo/bcms_s3"
    gem.authors = ["Anthony Underwood"]

    gem.files = "app/controllers/cms/content_controller.rb"
    gem.files << "app/models/attachment.rb"
    gem.files << "lib/bcms_s3.rb"
    gem.files << "lib/bcms_s3/routes.rb"

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end