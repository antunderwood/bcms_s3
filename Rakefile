# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.


require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "bcms_s3"
    gem.summary = %Q{This is a browsercms (browsercms.org) module to allow the facility to have attachments stored on Amazon S3. Also there is the option to change caching to suit heroku and/or use 'www' as the prefix for the non-cms site.
Based on original work by Neil Middleton}
    gem.email = "email2ants@gmail.com"
    gem.homepage = "http://github.com/aunderwo/bcms_s3"
    gem.authors = ["Anthony Underwood"]

    gem.files = "lib/bcms_s3.rb"
    gem.files << "lib/bcms_s3/routes.rb"
    gem.files << "lib/bcms_s3/s3_module.rb"
    gem.files << "templates/blank.rb"

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end