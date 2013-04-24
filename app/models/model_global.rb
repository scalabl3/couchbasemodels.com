module ModelGlobal
  include DocumentStore

  def get_new_uid
    ModelGlobal.get_new_uid
  end
  
  def get_new_page_id
    ModelGlobal.get_new_page_id
  end

  # returns the number of users signed up
  def num_users
    ModelGlobal.num_users
  end
  
  def num_pages
    ModelGlobal.num_pages
  end

  def add_super_user(uid)
    ModelGlobal.add_super_user(uid)
  end

  def remove_super_user(uid)
    ModelGlobal.remove_super_user(uid)
  end

  # returns the number of users signed up
  def num_superusers
    ModelGlobal.num_superusers
  end
  
  def find_page_id_by_url(page_url, get_page_object = false)
    ModelGlobal.find_page_id_by_url(page_url, get_page_object)
  end

  # returns nil if the user isn't found, by default it returns a user object, set get_user_object to false if you just want the uid
  def find_user_by_github_id(github_id, get_user_object = true)
    ModelGlobal.find_user_by_github_id(github_id, get_user_object)
  end

  def find_comment_by_page_and_id(page_id, comment_id)
    ModelGlobal.find_comment_by_page_and_id(page_id, comment_id)
  end

  # returns nil if the user isn't found, by default it returns a user object, set get_user_object to false if you just want the uid
  def find_user_by_uid(uid, get_user_object = true)
    ModelGlobal.find_user_by_uid(uid, get_user_object)
  end

  def get_multiple_users_by_uid(uids, get_user_objects = true)
    ModelGlobal.get_multiple_users_by_uid(uids, get_user_objects)
  end


  class << self
    include DocumentStore

    def find_page_id_by_url(page_url, get_page_object = false)
      
      if get_page_object
        
      else
        get_document("url::#{page_url}")
      end
    end

    # returns nil if the user isn't found, by default it returns a user object, set get_user_object to false if you just want the uid
    def find_user_by_github_id(github_id, get_user_object = true)
      # make sure it's a string...
      github_id = github_id.to_s

      if get_user_object
        uid = get_document("gh::#{github_id}")
        u = nil
        u = User.new({ :retrieve => true, :uid => uid }) if uid
        u
      else
        get_document("gh::#{github_id}")
      end
    end


    # returns nil if the user isn't found, by default it returns a user object, set get_user_object to false if you just want the uid
    def find_user_by_uid(uid, get_user_object = true)
      # make sure it's a string...
      uid = uid.to_s

      if get_user_object
        u = get_document("u::#{uid}")
        u = User.new({ :retrieve => true, :uid => uid }) if u
        u
      else
        get_document("u::#{uid}")
      end
    end
    
    def find_comment_by_page_and_id(page_id, comment_id)
      c = get_document("p::#{page_id}::#{comment_id}")
      return nil unless c
      c = Comment.new({ :retrieve => true, :page_id => page_id, :comment_id => comment_id })
      c
    end
    

    def get_multiple_users_by_uid(uids, get_user_objects = true)
      uids.each_with_index do |u, i|
        uids[i] = "u::#{u.to_s}"
        raise ArgumentError, "get_multiple_users_by_uid requires that all uid's in array are non-nil" if u.nil?
      end

      if get_user_objects
        uid_docs = get_documents(uids)
        users = []
        uid_docs.each_with_index do |doc, i|
          users[i] = User.new( uid_docs[i] ) if uid_docs[i]
        end
        users
      else
        get_documents(uids)
      end
    end


    # returns the number of users signed up
    def num_users
      Analytics.num_users
    end
    
    def num_pages
      Analytics.num_pages
    end

    # returns a new uid for creating/saving a new user
    def get_new_uid
      Analytics.increment_num_users
    end

    def get_new_page_id
      Analytics.increment_num_pages
    end
    
    def add_super_user(uid)

      # Make sure the user counter is set in Couchbase
      initialize_document("superusers::count", 0)

      # Create the Super Users list-array
      initialize_document("superusers", { :users => [] })

      doc = get_document("superusers")
      users = doc[:users]
      unless users.include?(uid)
        users.unshift(uid)

        doc[:users] = users

        replace_document("superusers", doc)
        increase_atomic_count("superusers::count")
      end
    end

    def remove_super_user(uid)
      # Make sure the user counter is set in Couchbase
      initialize_document("superusers::count", 0)

      # Create the Super Users list-array
      initialize_document("superusers", { :users => [] })

      doc = get_document("superusers")
      users = doc[:users]
      users.delete(uid)
      doc[:users] = users

      replace_document("superusers", doc)
      decrease_atomic_count("superusers::count")
    end

    # returns the number of users signed up
    def num_superusers
      # retrieve the current user count
      count = get_document("superusers::count")

      return 0 unless count
      return count
    end

    def get_super_users
      doc = get_document("superusers")
      users = doc[:users]

      superusers = []
      users.each do |uid|
        u = User.new({ :retrieve => true, :uid => uid })
        superusers.push(u)
      end
      superusers
    end
  end
end