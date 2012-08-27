class Comment < ModelBase
  include DocumentStore
  include ModelGlobal
  include ErrorCodes
  
  fattrs :uid, :page_id, :comment_text, 
  
  def initialize(attr = {})
    attr = Map.new(attr)
    super
    fattrs.each_with_index{|a,i| send "#{a}!"} # initialize all fattrs so they exist, *must be initialized*
    
    # load passed in parameter attributes
    load_parameter_attributes attr

    # Typically in Couchbase you want to create document and then modify instead of waiting for save method at the end
    # we pass in :create => true to create this user, then we can modify the user later
    # We'll make sure it's valid by checking to see if the user already exists
    if attr.has_key_and_value?(:create)
      #raise "trying to create user -- user exists already (via facebook_id)" if @facebook_id && User.find_user_by_facebook_id(@facebook_id)
      #raise "trying to create user -- user exists already (via email)" if @email && User.find_user_by_email(@email)
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

  def create_doc_keys
    unless @doc_keys_setup
      @docs = {}

      @docs[:user] = "u::#{uid}"
      @docs[:github_ref] = "gh::#{@github_id}"
      @docs[:num_comments_made]  = "u::#{uid}::num_comments_made"
      @docs[:language_pref] = "u::#{uid}::language_pref"

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

    if @uid && @github_id

      initialize_document(@docs[:user], self.to_hash)

      # initialize if we have a facebookID and userID, simple for now
      initialize_document(@docs[:github_ref], @github_id)
      initialize_document(@docs[:language_pref], "ruby")

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
    Rails.logger.debug("CREATE_NEW")
    @uid = get_new_uid
    Rails.logger.debug(@uid)
    create_default_docs
    if @super_user
      add_super_user(@uid)
    end
  end

  def load_persisted
    if @github_id
      @uid = get_document("gh::#{@github_id}")
    end

    if @uid
      load_parameter_attributes get_document("u::#{@uid}")
      create_default_docs
    else
      raise "User Not Found"
    end
  end
  
  
end