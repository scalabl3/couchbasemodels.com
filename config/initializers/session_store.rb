=begin
# Be sure to restart your server when you modify this file.
require 'action_dispatch/middleware/session/couchbase_store'
CouchbaseModels::Application.config.session_store :couchbase_store


cache_options = {
  :expire_after => 4320.minutes, # 3 days
  :couchbase => {
		:hostname => Yetting.couchbase_host, 
		:pool => "default",
  	:bucket => Yetting.couchbase_bucket,
  	:port => 8091, 
		:default_format => :marshal
	}
}

Rails.logger.debug cache_options.inspect

CouchbaseModels::Application.config.session_storage = :couchbase_store, cache_options

=end


# Using Dalli Gem 
# require 'action_dispatch/middleware/session/dalli_store'
# 
# Rails.application.config.session_store :dalli_store,
#                                        :memcache_server => Yetting.couchbase_servers,
#                                        :namespace => '_cbmodels_session',
#                                        :key => '_cbmodels_session',
#                                        :expire_after => 1.day,
#                                        :username => Yetting.couchbase_bucket,
#                                        :password => Yetting.couchbase_password  






=begin
# Using Cookies Only
#CouchbaseModels::Application.config.session_store :cookie_store, key: '_CouchbaseModels_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# CouchbaseModels::Application.config.session_store :active_record_store

=end