module Langchain::Tool
  class DirectionsGateway
    extend Langchain::ToolDefinition
    include Langchain::DependencyHelper

    define_function  :get_directions, description: "Retrieves directions for two given locations by car" do
      property :origin, type: "string", description: "The starting point of the directions", required: true
      property :destination, type: "string", description: "The destination of the directions", required: true
    end

    define_function :get_coordinates, description: "Retrieves the coordinates for a given location" do
      property :location, type: "string", description: "The location to get the coordinates for", required: true
    end

    def get_directions(origin:, destination:)
      Langchain.logger.debug("DirectionsGateway: Getting directions from #{origin} to #{destination}")

      response = conn.get("/directions/v2/route?from=#{origin}&to=#{destination}")
      JSON.parse(response.body, symbolize_names: true)
    end

    def get_coordinates(location:)
      Langchain.logger.debug("DirectionsGateway: Getting coordinates for #{location}")

      response = conn.get("/geocoding/v1/address?location=#{location}")
      JSON.parse(response.body, symbolize_names: true)
    end

    def conn = Faraday.new(url: "https://www.mapquestapi.com") do |faraday|
      faraday.params['key'] = ENV["MAPQUEST_API_KEY"]
    end
  end
end
