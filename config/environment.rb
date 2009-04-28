# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'enumerator'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on.
  # They can then be installed with "rake gems:install" on new installations.
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem 'gettext',  :lib => 'gettext/rails', :version => '1.93.0'
  config.gem 'diff-lcs', :lib => 'diff/lcs'
  config.gem 'oauth'
  config.gem 'haml'
  config.gem 'moro-repim', :lib => 'repim', :source => 'http://gems.github.com/'
  config.gem 'moro-scope_do', :lib => 'scope_do', :version => '>=0.1.1', :source =>  'http://gems.github.com/'
  config.gem 'moro-piki_doc', :lib => 'piki_doc', :source => 'http://gems.github.com/'
  config.gem 'mislav-will_paginate', :lib => 'will_paginate', :version=> '>=2.3.6', :source => 'http://gems.github.com/'
  config.gem 'openskip-skip_embedded', :lib => 'skip_embedded', :version => '>=0.9.2', :source => 'http://gems.github.com'

  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  config.plugins = %w[
    haml
    jrails
    open_id_authentication
    oauth-plugin
    attachment_fu
    moro-scope_do
  ]

  config.plugins += %w[rails-footnotes] if Rails.env == "development"
  config.plugins << "openskip-skip_embedded" if Gem.source_index.any?{|_,y| y.name =~ /(?:[:ascii:]+-)?openskip-skip_embedded/  }

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
  config.time_zone = 'UTC'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_skip-wiki.git_session',
    :secret      => '113cc51becb29e738e22dbd30934eddeef6cd9bdfb2ba6b5e24b309fbb40b5c1dfc0c9b020589f0bd631ecc1891e06531856909802cd9d07edaaeed829b85eaa'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
end

