class Comment < ModelBase
  include DocumentStore
  include ModelGlobal
  include ErrorCodes
  include ApiHelper
  
	fattr :type, :default => self.to_s.downcase
	fattr :approved, :default => false
  fattrs :uid, :page_id, :comment_id, :comment_text
  fattr :timestamp => Time.now.utc.to_i
  
  def initialize(attr = {})
    attr = Map.new(attr) unless attr.is_a? Map
    super
    fattrs.each_with_index{|a,i| send "#{a}!"} # initialize all fattrs so they exist, *must be initialized*
    
    # load passed in parameter attributes
    load_parameter_attributes attr

    # We'll make sure it's valid by checking to see if the user already exists
    if attr.has_key_and_value?(:create)
      #raise "trying to create user -- user exists already (via uid)" if @uid && User.find_user_by_uid(@uid)
      create_new
    end

    # Either we are creating or retrieving a user, if we are retrieving, we need at least one of three possible user
    # identifiers to be passed in as an attribute/parameter
    if attr.has_key_and_value?(:retrieve)
      #unless attr.has_key_and_value?(:facebook_id) || attr.has_key_and_value?(:email) || attr.has_key_and_value?(:uid)
      #  raise "trying to retrieve user -- requires facebook_id, email or uid"
      #end
      load_persisted
    end

    self
  end
  
  private

  def create_doc_keys(reset = false)
    if (@doc_keys_setup == false || reset)
      @docs = {}

      @docs[:comment] = "p::#{@page_id}::#{@comment_id}"
      @docs[:num_comments]  = "p::#{@page_id}::num_comments"

      @doc_keys_setup = true


      # Since we have a lot of stats keys, use some metaprogramming to define the methods for get and increment
      @docs.each do |method,v|

        if method.to_s.starts_with?("num_")

          # create get method for document symbol that starts with num_
          # i.e. def num_site_views
          self.class.send(:define_method, method) do
            get_document(@docs[method])
          end

					# I don't want to expose increment
					
          # create increment method for document symbol that starts with num_
          # i.e. def increment_site_views
          #self.class.send(:define_method, method.to_s.gsub("num", "increment").to_sym) do
          #  increase_atomic_count(@docs[method])
          #end

        end
      end


    end
  end

  def create_default_docs
    create_doc_keys unless doc_keys_setup

    if @comment_id && @uid && @page_id

      initialize_document(@docs[:comment], self.to_hash)

      pubnub_message({ :message => "comment#create_new", :key => @docs[:comment], :values => get_document(@docs[:comment]) } )
      
      ### STATS, initialize all docs that start with num_ with a count of 0
      @docs.each do |doc_key,v|
        if doc_key.to_s.starts_with?("num_")
          initialize_document(@docs[doc_key], 0)
        end
      end
    else
      pubnub_message({ :message => "didn't create new comment doc"})
    end
  end


  # create a new user and associated documents
  def create_new
    create_doc_keys(true)
    initialize_document(@docs[:num_comments], 0)

		@comment_id = increase_atomic_count(@docs[:num_comments])

		create_doc_keys(true)

    create_default_docs
  end

  def load_persisted
    if @page_id && @comment_id
			create_doc_keys(true)
      load_parameter_attributes get_document(@docs[:comment])
      create_default_docs
    else
      raise "Comment Document Not Found (page_id and/or comment_id not supplied)"
    end
  end
  
  
end