# A [BrowserCMS](http://www.browsercms.org) module to allow storage of images and files on the Amazon S3 storage facility
## Using S3 for file storage
To enable S3 file storage set Cms::S3.enabled in config/initializers/browsercms.rb (create this if it does not exist) to true.  Ensure that you as provide a s3.yml file that contains your credentials and bucket.
This should be in the following format

    access_key_id: your AWS access key
    secret_access_key: your AWS secret access key
    bucket: your unique bucket name

## Using this module with [Heroku](http://heroku.com)
If using this module in conjunction with deployment on heroku you should probably turning heroku caching on by setting Cms::S3.heroku_caching in config/initializers/browsercms.rb to true.

In order to avoid putting your secret AWS key in the s3.yml file, you can take advantage of [heroku's config vars](http://docs.heroku.com/config-vars). Use ERB to read the values from the environment.  This way you can safely commit your s3.yml file to the repository without revealing your amazon credentials.

    access_key_id: <%= ENV['s3_access_key_id'] %>
    secret_access_key: <%= ENV['s3_secret_access_key'] %>
    bucket: <%= ENV['s3_bucket'] %>

For developing on your local machine, export the s3 variables to your environment.

    export s3_access_key_id='your AWS access key'
    export s3_secret_access_key='your AWS secret access key'
    export s3_bucket='your unique bucket name'

Set the config vars on heroku to get it working there as well.

    heroku config:add s3_access_key_id='your AWS access key'
    heroku config:add s3_secret_access_key='your AWS secret access key'
    heroku config:add s3_bucket='your unique bucket name'

## www prefix for non cms urls
If your non cms domain is www.myapp.com rather than app.com this can be enabled by setting Cms::S3.www_domain_prefix in config/initializers/browsercms.rb to true.

## Important things to note
1. The s3.yml should be excluded from public repositories (e.g github) since it contains your secret AWS key which should **never** be revealed to the public.
2. Changing from local storage to S3 storage will require you to re-upload all your files (or copy the tree to s3)
3. This module requires the RightAWS gem from RightScale (sudo gem install right_aws)

##### Based on original work on S3 storage for BrowserCMS by [Neil Middleton](http://github.com/neilmiddleton/)
