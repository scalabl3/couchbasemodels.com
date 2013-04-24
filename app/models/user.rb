class User < ModelBase
  include DocumentStore
  include ModelGlobal
  include ErrorCodes
  include ModelValidations
  include ApiHelper

  # by default include the type, which is the class name downcased
  fattr :type, :default => self.to_s.downcase

  fattrs :uid, :github_username
  fattrs :github_id, :avatar_url, :gravatar_id, :github_access_token
  fattr  :super_user, :default => false

  def initialize(attr = {})
    @super_user = false
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


  #### PRIVATE/DEFAULT/OVERLOADED METHODS

  private

  def create_doc_keys
    unless @doc_keys_setup
      @docs = {}

      @docs[:user] = "u::#{@uid}"
      @docs[:github_ref] = "gh::#{@github_id}"
      @docs[:num_comments_made]  = "u::#{@uid}::num_comments_made"
      @docs[:language_pref] = "u::#{@uid}::language_pref"

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
      initialize_document(@docs[:github_ref], @uid)
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


  #### PROPERTIES & PROPERTY OVERLOADS
  public

  def update
    if @uid
      replace_document(@docs[:user], self.to_hash)
    end
  end
  
  def is_super_user?
    @super_user
  end

  def is_superuser?
    @super_user
  end

  def language_pref
    self.language_preference
  end

  def language_preference
    get_document(@docs[:language_pref])
  end

  def action_submit_comment(page, comment_text)
    c_hash = { 
      :create => true,
      :uid => @uid, 
      :page_id => page,
      :comment_text => comment_text     
    }
    if validate_submit_comment(page, comment_text)
      new_comment = Comment.new(c_hash)
      
      result = { :success => true,
                 :comment_id => new_comment.comment_id,
                 :comment_text => new_comment.comment_text,
                 :uid => @uid,
                 :error_name => nil,
                 :error_code => nil,
                 :reason => nil,
                 :help_text => nil,
                 :backtrace => nil}
    end
    
  rescue Exception => e
    raise e unless COMMENTING_ERRORS.has_key?(e.message.to_sym)
    result = {
        :success => false,
        :comment_id => nil,
        :error_name => e.message.to_s, 
        :error_code => ErrorCodes::COMMENTING_ERRORS[e.message.to_sym][0],
        :reason => ErrorCodes::COMMENTING_ERRORS[e.message.to_sym][1],
        :help_text => ErrorCodes::COMMENTING_ERRORS[e.message.to_sym][2],
        :backtrace => e.backtrace.inspect
    }
  end
  #### USER ACTIONS - the things the User can DO

=begin
  def action_create_new_radlib(radlib_title, radlib_text_array, original_sentences)

    if validate_create_new_radlib(radlib_title, radlib_text_array)

      new_radlib = RadlibStory.new ({ :create => true,
                                      :radlib_title => radlib_title,
                                      :radlib_text_array => radlib_text_array,
                                      :author_uid => @uid,
                                      :original_sentences => original_sentences})

      add_radlib_to_created(new_radlib.radlib_id)

      # Run Analytics on new data
      Analytics.analyze_user(self)

      result = { :success => true,
                 :radlib_id => new_radlib.radlib_id,
                 :radlib_url => Yetting.domain + "r/#{new_radlib.radlib_id}",
                 :error_name => nil,
                 :error_code => nil,
                 :reason => nil,
                 :help_text => nil,
                 :backtrace => nil}
    end

  rescue Exception => e
    raise e unless RADLIB_CREATE_ERRORS.has_key?(e.message.to_sym)
    result = {
        :success => false,
        :radlib_id => nil,
        :radlib_url => nil,
        :error_name => e.message.to_s,
        :error_code => ErrorCodes::RADLIB_CREATE_ERRORS[e.message.to_sym][0],
        :reason => ErrorCodes::RADLIB_CREATE_ERRORS[e.message.to_sym][1],
        :help_text => ErrorCodes::RADLIB_CREATE_ERRORS[e.message.to_sym][2],
        :backtrace => e.backtrace.inspect
    }
  end
=end






  #### PUBLIC METHODS
  public



  #### CLASS METHODS



end
