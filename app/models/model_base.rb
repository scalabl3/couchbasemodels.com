class ModelBase
  include Term::ANSIColor
  include FattrJSON

  attr_accessor :docs, :doc_keys_setup, :observer_data, :mailer_data

  def initialize(*attributes)
    @doc_keys_setup = false
    @docs = Map.new
    @observer_data = Map.new
    @mailer_data = Map.new
  end

  def load_parameter_attributes(attributes = {})
    if !attributes.nil?
      attributes.each do |name, value|
        setter = "#{name}="
        next unless respond_to?(setter)
        send(setter, value)
      end
    end
  end

  def create_doc_keys
    Rails.logger.warn(intense_red( "ModelBase#create_doc_keys -- Override this implementation! #{self.class}::#{this_method}") + yellow(" by #{calling_method}"))
  end

  def create_default_docs
    Rails.logger.warn(intense_red( "ModelBase#create_doc_keys -- Override this implementation! #{self.class}::#{this_method}") + yellow(" by #{calling_method}"))
  end

  def doc_keys_setup
    not @docs.empty?
  end

  # Retrieve all associated documents setup in @docs (keys), and return as a hash (useful for debugging)
  def retrieve_all_docs
    return nil unless @doc_keys_setup

    doc_hash = {}

    @docs.each_pair do |k,v|
      doc_hash[v] = get_document(v)
    end

    doc_hash
  end
end




