require 'open-uri'
require 'net/http'
require 'timeout'

class HomeController < ApplicationController

  def search
    
    @maps = []
    @q = params[:q]
    
    @search = Map.search do
      keywords params[:q]
    end
    @results = @search.results
    
    # @results = []
    # @q = params[:q]
    # 
    # unless params[:q].nil?
    #   maps = Map.search do
    #     keywords params[:q]
    #   end.results
    #   
    #   annotations = Annotation.search do
    #     keywords params[:q]
    #  end.results
    #   
    #   
    #   
    #   # get the maps from the annotations and tags and put them into one array
    #   annotation_maps = annotations.collect { |a| a.map }
    #   
    #   @results = maps.concat(annotation_maps).uniq
    # #  @results = maps.concat(tag_maps).uniq
    # end
    
    respond_to do |format|
      format.html # search.html.erb
      format.xml  { render :xml => @maps }
    end
    
  end
  
  def status
    
    @status = {
      maps:       {
        description: "Map resources and tilesets",
        url: Rails.configuration.map_base_uri,
        status: test_status(Rails.configuration.map_base_uri)
      },
      geonames: {
        description: "GeoNames lookup service",
        url: Rails.configuration.geoname_query,
        status: test_status(Rails.configuration.geoname_query)
      },
      wikipedia: {
        description: "Wikipedia Miner lookup service",
        url: Rails.configuration.wikipedia_miner_uri,
        status: test_status(Rails.configuration.wikipedia_miner_uri)
      },
      dbpedia: {
        description: "DBpedia SPARQL request service",
        url: Rails.configuration.dbpedia_sparql_uri,
        status: test_status(Rails.configuration.dbpedia_sparql_uri)
      }
    }
    
    respond_to do |format|
      format.html # status.html.erb
      format.xml { render :xml => @status }
      format.json { render :json => @status }
    end
  end
  
  # tests the status for a given URL
  def test_status(test_url)
    begin
      url = URI.parse(test_url)
      ret = Net::HTTP.get_response(url).code
      puts url
      puts ret
      status = (["200", "301", "302", "400"].include? ret) ? :available : :unavailable
      puts status
    rescue
      status = :unavailable
    end
    status
  end

end
