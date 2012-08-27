require 'couchbase'
require 'map'

module DocumentStore
  include Term::ANSIColor
  
  COUCH = Couchbase.new({
      :hostname => Yetting.couchbase_host,
      :pool => "default",
      :bucket => Yetting.couchbase_bucket,
      :username => Yetting.couchbase_bucket,
      :password => Yetting.couchbase_password,
      :port => 8091
  })

  #### INSTANCE METHODS

  def document_exists?(key)
    return nil unless key
    DocumentStore.document_exists?(key)
  end

  def initialize_document(key, value, args={})
    return nil unless key
    DocumentStore.initialize_document(key, value, args)
  end

  def create_document(key, value, args={})
    return nil unless key
    DocumentStore.create_document(key, value, args) # => if !quiet, Generates Couchbase::Error::KeyExists if key already exists
  end

  def replace_document(key, value, args = {})
    return nil unless key
    DocumentStore.replace_document(key, value, args)
  end

  def get_document(key, args = {})
    return nil unless key
    DocumentStore.get_document(key, args)
  end

  def get_documents(keys = [], args = {})
    return nil unless keys || keys.empty?
    DocumentStore.get_documents(keys, args)
  end

  def delete_document(key, args={})
    return nil unless key
    DocumentStore.delete_document(key, args)
  end

  # @param args :amount => Fixnum||Integer, increases by that
  def increase_atomic_count(key, args={})
    return nil unless key
    DocumentStore.increase_atomic_count(key, args)
  end

  def decrease_atomic_count(key, args={})
    return nil unless key
    DocumentStore.decrease_atomic_count(key, args)
  end

  # preferred way is to use create/replace to make sure there are no collisions
  def force_set_document(key, value, args={})
    return nil unless key
    DocumentStore.force_set_document(key, value, args)
  end



  # end Instance Methods
  #####################################################################
  #### CLASS METHODS

  class << self

    def delete_all_documents!
      COUCH.flush
    end

    def document_exists?(key)
      return nil unless key

      # Save quiet setting
      tmp = COUCH.quiet

      # Set quiet to be sure
      COUCH.quiet = true

      doc = COUCH.get(key)

      # Restore quiet setting
      COUCH.quiet = tmp

      !doc.nil?
    end

    def initialize_document(key, value, args={})
      return nil unless key
      COUCH.quiet = true
      doc = DocumentStore.get_document( key )
      (value.is_a?(Fixnum) || value.is_a?(Integer) ? COUCH.set( key, value ) : COUCH.add( key, value )) unless doc
    end

    def create_document(key, value, args={})
      return nil unless key
      COUCH.quiet = args[:quiet] || true
      COUCH.add(key, value, args) # => if !quiet, Generates Couchbase::Error::KeyExists if key already exists
    end

    def replace_document(key, value, args = {})
      return nil unless key
      COUCH.quiet = args[:quiet] || true
      COUCH.replace(key, value) # => if !quiet, Generates Couchbase::Error::NotFound if key doesn't exist
    end

    def get_document(key, args = {})
      return nil unless key
      COUCH.quiet = args[:quiet] || true
      doc = COUCH.get(key, args)
      doc.is_a?(Hash) ? Map.new(doc) : doc
    end

    def get_documents(keys = [], args = {})
      return nil unless keys || keys.empty?
      values = COUCH.get(keys, args)

      if values.is_a? Hash
        tmp = []
        tmp[0] = values
        values = tmp
      end
      # convert hashes to Map (subclass of Hash with *better* indifferent access)
      values.each_with_index do |v, i|
        values[i] = Map.new(v) if v.is_a? Hash
      end

      values
    end

    def delete_document(key, args={})
      return nil unless key
      COUCH.quiet = args[:quiet] || true
      COUCH.delete(key)
    end

    def increase_atomic_count(key, args={})
      return nil unless key
      COUCH.quiet = args[:quiet] || true
      COUCH.incr(key, args[:amount] || 1)
    end

    def decrease_atomic_count(key, args={})
      return nil unless key
      COUCH.quiet = args[:quiet] || true
      COUCH.decr(key, args[:amount] || 1)
    end

    # preferred way is to use create/replace instead of this to make sure there are no collisions
    def force_set_document(key, value, args={})
      return nil unless key
      COUCH.quiet = args[:quiet] || true
      COUCH.set(key, value, args)
    end

  end# end ClassMethods

  #####################################################################




end