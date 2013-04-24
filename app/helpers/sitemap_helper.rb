module SitemapHelper
  
  def get_last_modified(controller, viewfile)
    modified = Date.parse(File.mtime("#{Rails.root}/app/views/#{controller}/#{viewfile}.html.erb").to_s)
    modified.strftime("%Y-%m-%d")
  end 
  
end
