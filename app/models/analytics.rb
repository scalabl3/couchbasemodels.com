##
## Site-wide Analytics
##
# Since this class is used site-wide, and tracks across sessions,
#   we are making the variables class constants, and all methods are class methods,
#   initialize should be called *once* on app init or after deleting all documents (db bucket flush)
#   to setup default documents and keys
#
class Analytics

  USER_COUNT_START    = 10000
  PAGE_COUNT_START    = 10000

  # note: for the :most_x keys, we generate an additional key, appending ::min for minimum value to get on list
  # see create_default_docs() to see the pattern
  DOCS = {
      :user_count => "u::count",
      :page_count => "p::count",

      :superusers => "superusers",
      :superusers_count => "superusers::count",
      
      :site_views_count => "site::views",  # total site views, for all pages
      :site_comments_count => "site::comments" # total site comments made for all fillins for all users

  }.freeze

  def initialize(attr = {})
    #self.class.create_default_docs
  end

  # Make all these methods class methods
  class << self
    include Term::ANSIColor
    include DocumentStore
    include ModelGlobal

    def create_default_docs
      DocumentStore.initialize_document(DOCS[:user_count], USER_COUNT_START)
      DocumentStore.initialize_document(DOCS[:page_count], PAGE_COUNT_START)

      DocumentStore.initialize_document(DOCS[:site_views_count], 0)
      DocumentStore.initialize_document(DOCS[:site_comments_count], 0)

    end

    ## ********************************************************************************
    ## Num Users
    ## ********************************************************************************

    def num_users
      # retrieve the current user count
      count = DocumentStore.get_document(DOCS[:user_count])

      # return difference between current count and start
      count - USER_COUNT_START
    end

    def increment_num_users
      DocumentStore.increase_atomic_count(DOCS[:user_count])
    end

    ## ********************************************************************************
    ## Num Pages
    ## ********************************************************************************

    def num_pages
      # retrieve the current user count
      count = DocumentStore.get_document(DOCS[:page_count])

      # return difference between current count and start
      count - PAGE_COUNT_START
    end

    def increment_num_pages
      DocumentStore.increase_atomic_count(DOCS[:page_count])
    end


    ## ********************************************************************************
    ## Site Views
    ## ********************************************************************************

    def num_site_views
      DocumentStore.get_document(DOCS[:site_views_count])
    end

    def increment_site_views
      DocumentStore.increase_atomic_count(DOCS[:site_views_count])
        # the only time you would need to rescue, is if it didn't initialize
    rescue
      Analytics.new
      DocumentStore.increase_atomic_count(DOCS[:site_views_count])
    end



    ## ********************************************************************************
    ## Site Comments
    ## ********************************************************************************

    def num_site_comments
      DocumentStore.get_document(DOCS[:site_comments_count])
    end

    def increment_site_comments
      DocumentStore.increase_atomic_count(DOCS[:site_comments_count])
    end

  end # class method definitions
end