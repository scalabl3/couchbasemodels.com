require 'couchbase'
require 'map'

module DocumentStore
  include Term::ANSIColor


  setting_hash = { :node_list => Yetting.couchbase_servers,
    :pool => "default",
    :bucket => Yetting.couchbase_bucket,
    :port => 8091
  }
  if (Yetting.couchbase_password && !Yetting.couchbase_password.empty?)
    setting_hash[:username] = Yetting.couchbase_bucket
    setting_hash[:password] = Yetting.couchbase_password
  end

  
  CB = Couchbase.connect(setting_hash)
  
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
      CB.flush
    end

    def document_exists?(key)
      return nil unless key

      # Save quiet setting
      tmp = CB.quiet

      # Set quiet to be sure
      CB.quiet = true

      doc = CB.get(key)

      # Restore quiet setting
      CB.quiet = tmp

      !doc.nil?
    end

    def initialize_document(key, value, args={})
      return nil unless key
      CB.quiet = true
      doc = DocumentStore.get_document( key )
      (value.is_a?(Fixnum) || value.is_a?(Integer) ? CB.set( key, value ) : CB.add( key, value )) unless doc
    end

    def create_document(key, value, args={})
      return nil unless key
      CB.quiet = args[:quiet] || true
      CB.add(key, value, args) # => if !quiet, Generates Couchbase::Error::KeyExists if key already exists
    end

    def replace_document(key, value, args = {})
      return nil unless key
      CB.quiet = args[:quiet] || true
      CB.replace(key, value) # => if !quiet, Generates Couchbase::Error::NotFound if key doesn't exist
    end

    def get_document(key, args = {})
      return nil unless key
      CB.quiet = args[:quiet] || true
      doc = CB.get(key, args)
      doc.is_a?(Hash) ? Map.new(doc) : doc
    end

    def get_documents(keys = [], args = {})
      return nil unless keys || keys.empty?
      values = CB.get(keys, args)

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
      CB.quiet = args[:quiet] || true
      CB.delete(key)
    end

    def increase_atomic_count(key, args={} )
      return nil unless key
      CB.quiet = args[:quiet] || true
      CB.incr(key, args[:amount] || 1)
    end

    def decrease_atomic_count(key, args={})
      return nil unless key
      CB.quiet = args[:quiet] || true
      CB.decr(key, args[:amount] || 1)
    end

    # preferred way is to use create/replace instead of this to make sure there are no collisions
    def force_set_document(key, value, args={})
      return nil unless key
      CB.quiet = args[:quiet] || true
      CB.set(key, value, args)
    end

  end# end ClassMethods

  #####################################################################

end