class CommentCollection < ModelBase
  include DocumentStore
  include ModelGlobal
  include ErrorCodes
  
  fattrs :page_id
  
  def initialize(attr = {})
    attr = Map.new(attr)
    super
    fattrs.each_with_index{|a,i| send "#{a}!"} # initialize all fattrs so they exist, *must be initialized*
    
    # load passed in parameter attributes
    load_parameter_attributes attr

    if attr.has_key_and_value?(:create)
      #raise "trying to create user -- user exists already (via facebook_id)" if @facebook_id && User.find_user_by_facebook_id(@facebook_id)
      create_new
    end

    if attr.has_key_and_value?(:retrieve)
      load_persisted
    end

    self
  end
  
  private

  def create_doc_keys
    unless @doc_keys_setup
      @docs = {}
      @docs[:num_comments] = "#{@page_id}::comment_count"
      @doc_keys_setup = true

      # Since we have a lot of stats keys, use some metaprogramming to define the methods for get and increment
      @docs.each do |method,v|

        if method.to_s.starts_with?("num_")

          # create get method for document symbol that starts with num_
          # i.e. def num_site_views
          self.class.send(:define_method, method) do
            get_document(@docs[method])
          end

          # create increment method for document symbol that starts with num_
          # i.e. def increment_site_views
          self.class.send(:define_method, method.to_s.gsub("num", "increment").to_sym) do
            increase_atomic_count(@docs[method])
          end


        end
      end


    end
  end

  def create_default_docs
    create_doc_keys unless doc_keys_setup

    if @page_id
      
      ### STATS, initialize all docs that start with num_ with a count of 0
      @docs.each do |doc_key,v|
        if doc_key.to_s.starts_with?("num_")
          initialize_document(@docs[doc_key], 0)
        end
      end

    end
  end

  # create a new user and associated documents
  def create_new
    create_default_docs
  end

  def load_persisted
    create_default_docs
  end
  
  def add_comment
    
  end
  
  def reply_to_comment
    
  end
end