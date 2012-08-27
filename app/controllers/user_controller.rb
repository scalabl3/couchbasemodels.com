class UserController < ApplicationController
  include Term::ANSIColor
  include ModelGlobal

  def logout
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
    end

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