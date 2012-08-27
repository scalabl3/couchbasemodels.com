class ApiController < ApplicationController
  layout false
  
  def pull_comments
    page = params["page"]
    
    cc = CommentCollection.new({:retrieve => true, :page_id => page}) 
    result = { :success => true, :num_comments => cc.num_comments }

    respond_to do |format|
      format.json { render :json => result.to_json }
    end
  end
  
  def submit_comment
    page = params["page"]
    
    if session[:user]
      result = { :success => true }
    else
      result = { :success => false, :reason => "not authenticated" }
    end
    
    
    
    respond_to do |format|
      format.json { render :json => result.to_json }
    end
  end
end
