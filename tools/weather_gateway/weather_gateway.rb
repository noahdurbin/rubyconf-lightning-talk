module Langchain::Tool
  class WeatherGateway
    extend Langchain::ToolDefinition
    include Langchain::DependencyHelper

    define_function :get_weather, description: "Retrieves the weather for a given location" do
      property :coordinates, type: "string", description: "The location to get the weather for", required: true
    end

    def get_weather(coordinates:)
      Langchain.logger.debug("WeatherGateway: Getting weather for #{coordinates}")

      response = conn.get("/v1/forecast.json?q=#{coordinates}&days=5")
      JSON.parse(response.body, symbolize_names: true)
    end

    def conn
      Faraday.new(url: "https://api.weatherapi.com") do |faraday|
        faraday.params['key'] = ENV["WEATHER_API_KEY"]
      end
    end
  end
end