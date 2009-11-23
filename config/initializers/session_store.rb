# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_bcms_s3_session',
  :secret      => 'a5bdf5fc431371c7444bbd295b88b061f6bc7ef7a18d73470be8c0932a22645cf7d9cc0dd0070c98c02f2d62fcbe7bf0a7460a7b3f75bda9cbcb68d9a09c3019'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
