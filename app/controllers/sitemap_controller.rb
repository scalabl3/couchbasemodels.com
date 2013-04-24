class SitemapController < ApplicationController
  include SitemapHelper
  respond_to :xml
  layout nil
  
  def index

    @other = [
      { :url => "/", :priority => 0.5, :change_frequency => "weekly", :last_modified => get_last_modified("cbmodels_app", "index") },
      { :url => "/about", :priority => 0.5, :change_frequency => "weekly", :last_modified => get_last_modified("cbmodels_app", "about") },
      { :url => "/content", :priority => 0.5, :change_frequency => "weekly", :last_modified => get_last_modified("cbmodels_app", "content") },
      { :url => "/couchbase", :priority => 0.5, :change_frequency => "weekly", :last_modified => get_last_modified("cbmodels_app", "couchbase") }
    ]
    
    @indexes = [
      { :url => "/indexes", :priority => 0.5, :change_frequency => "daily", :last_modified => get_last_modified("cb_indexes", "index") },
      { :url => "/indexes/anatomy", :priority => 0.5, :change_frequency => "daily", :last_modified => get_last_modified("cb_indexes", "anatomy") },
      { :url => "/indexes/elastic_search", :priority => 0.5, :change_frequency => "daily", :last_modified => get_last_modified("cb_indexes", "elastic_search") },
      { :url => "/indexes/examples", :priority => 0.5, :change_frequency => "daily", :last_modified => get_last_modified("cb_indexes", "mr_examples") }
    ]
    
    @models = [
      { :url => "/models", :priority => 0.5, :change_frequency => "weekly", :last_modified => get_last_modified("cb_models", "index") },
      { :url => "/models/activity_stream", :priority => 0.5, :change_frequency => "weekly", :last_modified => get_last_modified("cb_models", "activity_stream") },
      { :url => "/models/product_catalog", :priority => 0.5, :change_frequency => "weekly", :last_modified => get_last_modified("cb_models", "product_catalog") },
    ]
    
    @patterns = [
      { :url => "/patterns", :priority => 0.5, :change_frequency => "monthly", :last_modified => get_last_modified("cb_patterns", "index") },
      { :url => "/patterns/autoversioning", :priority => 0.5, :change_frequency => "monthly", :last_modified => get_last_modified("cb_patterns", "autoversioning") },
      { :url => "/patterns/counter_id", :priority => 0.5, :change_frequency => "monthly", :last_modified => get_last_modified("cb_patterns", "counter_id") },
      { :url => "/patterns/lookup", :priority => 0.5, :change_frequency => "monthly", :last_modified => get_last_modified("cb_patterns", "lookup") },
      { :url => "/patterns/smart_cas", :priority => 0.5, :change_frequency => "monthly", :last_modified => get_last_modified("cb_patterns", "smart_cas") }
    ]
    
    @strategies = [
      { :url => "/strategies", :priority => 0.5, :change_frequency => "monthly", :last_modified => get_last_modified("cb_strategies", "index") },
      { :url => "/strategies/behavioral", :priority => 0.5, :change_frequency => "weekly", :last_modified => get_last_modified("cb_strategies", "behavioral") },
      { :url => "/strategies/complex", :priority => 0.5, :change_frequency => "monthly", :last_modified => get_last_modified("cb_strategies", "complex") },
      { :url => "/strategies/organic", :priority => 0.5, :change_frequency => "weekly", :last_modified => get_last_modified("cb_strategies", "organic") },
      { :url => "/strategies/simple", :priority => 0.5, :change_frequency => "monthly", :last_modified => get_last_modified("cb_strategies", "simple") }
    ]
    
    headers["Content-Type"] = "application/xml; charset=utf-8"
    render :layout => false, :content_type => "application/xml; charset=utf-8"
  end

end
