class ApiController < ApplicationController
  include ApiHelper
  
  layout false
  
  def pull_comments
    page = params["page"]
    remove_querystring = /[\w-]+/.match(page).to_s
    
    cc = CommentCollection.new({:retrieve => true, :page_id => remove_querystring})
    
    if cc
      result = { :success => true, :num_comments => cc.num_comments, :comment_list => cc.comment_list }
    else
      result = { :success => false, :num_comments => -1 }
    end
    
    respond_to do |format|
      format.json { render :json => result.to_json }
    end
  end
  
  def submit_comment
  
    page = params["page"]
    remove_querystring = /[\w-]+/.match(page).to_s
    comment_text = params["comment_text"]
    
    if session[:user]
      result = session[:user].action_submit_comment(remove_querystring, comment_text)
    else
      result = { :success => false, :radlib_id => nil,  :error_code => ErrorCodes::GLOBAL_ERRORS[:not_authenticated][0], :reason => ErrorCodes::GLOBAL_ERRORS[:not_authenticated][1]}
    end

		# publish to pubnub just to see it
    pubnub_comment("#{page} -- [#{remove_querystring}]", comment_text, session[:user] ? session[:user] : nil)
    
    respond_to do |format|
      format.json { render :json => result.to_json }
    end
    
    
  end
  
end
