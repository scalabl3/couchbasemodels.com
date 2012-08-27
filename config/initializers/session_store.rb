# Be sure to restart your server when you modify this file.

require 'action_dispatch/middleware/session/dalli_store'

Rails.application.config.session_store :dalli_store,
                                       :memcache_server => Yetting.couchbase_servers,
                                       :namespace => '_cbmodels_session',
                                       :key => '_cbmodels_session',
                                       :expire_after => Yetting.session_duration.minutes,
                                       :username => Yetting.couchbase_bucket,
                                       :password => Yetting.couchbase_password


#CouchbaseModels::Application.config.session_store :cookie_store, key: '_CouchbaseModels_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# CouchbaseModels::Application.config.session_store :active_record_store
