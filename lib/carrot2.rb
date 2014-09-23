require "carrot2/version"
require "builder"
require "rest-client"
require "json"

class Carrot2

  def initialize(endpoint = "http://localhost:8080/dcs/rest")
    @endpoint = endpoint
  end

  def cluster(documents, opts = {})
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
    xml.searchresult do |s|
      documents.each do |document|
        s.document do |d|
          d.title document[0]
          d.snippet document[1]
        end
      end
    end

    params = {
      "dcs.output.format" => "JSON",
      "dcs.clusters.only" => true,
      "dcs.c2stream" => xml.target!,
      "MultilingualClustering.defaultLanguage" => opts[:language] || "ENGLISH",
      :multipart => true
    }
    response = RestClient.post(@endpoint, params){|response, request, result| response }
    if response.code == 200
      JSON.parse(response.body)
    else
      raise "Bad response code from Carrot2 server: #{response.code}"
    end
  end

end
