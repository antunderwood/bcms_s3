# A [BrowserCMS](http://www.browsercms.org) module to allow storage of images and files on the Amazon S3 storage facility
## Using S3 for file storage
To enable S3 file storage set Cms::S3::Module.enabled in config/initializers/browsercms.rb (create this if it does not exist) to true.  Ensure that you as provide a s3.yml file that contains your credentials and bucket.
This should be in the following format

    access_key_id: your AWS access key
    secret_access_key: your AWS secret access key
    bucket: your unique bucket name

## Using this module with [Heroku](http://heroku.com)
If using this module in conjunction with deployment on heroku you should probably turning heroku caching on by setting Cms::S3::Module.heroku_caching in config/initializers/browsercms.rb to true.

## Important things to note
1. The s3.yml should be excluded from public repositories (e.g github) since it contains your secret AWS key which should **never** be revealed to the public.
2. Changing from local storage to S3 storage will require you to re-upload all your files (or copy the tree to s3)
3. This module requires the RightAWS gem from RightScale (sudo gem install right_aws)
