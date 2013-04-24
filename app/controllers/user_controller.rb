class UserController < ApplicationController
  include Term::ANSIColor
  include ModelGlobal
	include ApiHelper

  def logout
		if session[:user]
			pubnub_logout(session[:user])
		end
    #reset_session
    session[:user] = nil
    session[:access_token] = nil
    session[:user_gh] = nil
    session[:username] = nil
    session[:avatar] = nil
    session[:plang] = nil
    
    flash[:notice] = "You have been logged out!"
    redirect_to session[:return_page]
  end
  
  def authenticate
    auth = request.env["omniauth.auth"]
    Rails.logger.debug(intense_green(auth.inspect))
    Rails.logger.debug(auth.extra.raw_info.avatar_url)
    Rails.logger.debug("==============================================================================")


    user = find_user_by_github_id(auth.uid)

    Rails.logger.debug(user.class)

    unless user
      create_new_user = {
          :create => true,
          :github_id => auth.uid,
          :github_username => auth.info.nickname,
          :avatar_url => auth.extra.raw_info.avatar_url,
          :gravatar_id => auth.extra.raw_info.gravatar_id,
          :github_access_token => auth.credentials.token
      }
      user = User.new create_new_user
      Rails.logger.debug(user.class)
      Rails.logger.debug(user.inspect) if user
		else
			begin
				user.github_username = auth.info.nickname
      	user.avatar_url = auth.extra.raw_info.avatar_url
      	user.gravatar_id = auth.extra.raw_info.gravatar_id
      	user.github_access_token = auth.credentials.token      
				if Yetting.superuser_ids.include?(auth.uid)
					user.super_user = true
				else
					user.super_user = false
				end
				user.update
			rescue Exception => e
				pubnub_exception(e.class.to_s, e.message)
			end
    end

		pubnub_login(user)
		
    session[:user] = user
    session[:access_token] = auth.credentials.token
    session[:user_gh] = auth.uid
    session[:username] = auth.info.nickname
    session[:avatar] = auth.extra.raw_info.avatar_url
    session[:plang] = user.language_pref
    
    # we need at least one super user! so when creating user, check against the superuser set in config!
    if Yetting.superuser_ids.include?(auth.uid)
      session[:superuser] = true
    else
      session[:superuser] = false
    end
    
    flash[:notice] = "Welcome <strong>#{auth.info.nickname}</strong>, you have logged in!".html_safe
    redirect_to session[:return_page]
  end
  
  def make_comment
    
  end
  
  def retrieve_comments
    page_id = params["page_id"]
    puts page_id
  end

	def fix_uid
		c = DocumentStore::CB
		users = Couchbase::View.new(c, '_design/dokkey/_view/users')
		@user_list = []
		@github_refs = []
		users.each do |u|
			@user_list << u
			pubnub_userinfo(u)
			@github_refs << "#{u.key} - " + (c.get("gh::#{u.value['github_id']}")).to_s
			
			c.set("gh::#{u.value['github_id']}", u.value['uid'].to_s.to_i)
			
		end
	end
	
	def reset_comments
		cb = DocumentStore::CB
	  page_num_comments = Couchbase::View.new(cb, '_design/dokkey/_view/pages_num_comments')
	  @page_list = []
	  
	  page_num_comments.each do |p|
	    @page_list << p
	    cb.delete(p.id) if p
	  end
	  
	  
	  comments = Couchbase::View.new(cb, '_design/dokkey/_view/comments')
	  @comment_list = []
	  
	  comments.each do |c|
	    @comment_list << c
	    cb.delete(c.id) if c
	  end
	end
end

=begin
#<OmniAuth::AuthHash 
  credentials=#<Hashie::Mash expires=false token="fc27f1a5c2dd971607d0d97a1b8efbe6f966a648"> 
  extra=#<Hashie::Mash 
    raw_info=#<Hashie::Mash 
      avatar_url="https://secure.gravatar.com/avatar/2e2ecab3eb4c45790ac9ac5aff2cbd2d?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-140.png" 
      created_at="2011-09-13T18:09:07Z" 
      followers=6 
      following=11 
      gravatar_id="2e2ecab3eb4c45790ac9ac5aff2cbd2d" 
      html_url="https://github.com/jasdeepjaitla" 
      id=1048098 login="jasdeepjaitla" 
      public_gists=1 
      public_repos=7 
      type="User" 
      url="https://api.github.com/users/jasdeepjaitla">> 
  info=#<OmniAuth::AuthHash::InfoHash 
    email=nil 
    name=nil 
    nickname="jasdeepjaitla" 
    urls=#<Hashie::Mash Blog=nil GitHub="https://github.com/jasdeepjaitla">> 
  provider="github" 
  uid=1048098>
          
=end