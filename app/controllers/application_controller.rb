class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :save_return_page
  
  def save_return_page
    if request.fullpath != "/logout" && !request.fullpath.start_with?("/auth/") && !request.fullpath.start_with?("/api/")
      session[:return_page] = request.fullpath
    end
  end
  
  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :render_500
    rescue_from ActionController::RoutingError, :with => :render_404
    rescue_from AbstractController::ActionNotFound, :with => :render_404
    rescue_from ActionController::UnknownController, :with => :render_404
    rescue_from ActionController::UnknownAction, :with => :render_not_found
  end

  def raise_404
    raise ActionController::RoutingError, "Missing Route or Requested Invalid Page"
  end

  private
  def render_404(exception)
    @not_found_path = exception.message
    respond_to do |format|
      format.html { render template: 'errors/404', layout: 'layouts/application', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def render_500(exception)
    @error = exception
    @user = (session && session[:user] ? session[:user] : nil)

    respond_to do |format|
      format.html { render template: 'errors/500', layout: 'layouts/application', status: 500 }
      format.all { render nothing: true, status: 500}
    end
  end
end
