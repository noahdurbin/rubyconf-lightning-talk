require "dotenv/load"
require "langchain"
require "openai"
require "anthropic"
require "faraday"
require 'reline'

require_relative "./tools/directions_gateway/directions_gateway"
require_relative "./tools/weather_gateway/weather_gateway"

openai = Langchain::LLM::OpenAI.new(api_key: ENV["OPENAI_API_KEY"])
assistant = Langchain::Assistant.new(
  llm: openai,
  instructions: "You are a Meteorologist Assistant that is able to pull the weather for any location",
  tools: [
    Langchain::Tool::DirectionsGateway.new,
    Langchain::Tool::WeatherGateway.new
  ]
)

DONE = %w[done end eof exit].freeze

puts "Welcome to your travel assistant!"

def prompt_for_message
  puts "(multiline input; type 'end' on its own line when done. or exit to exit)"

  user_message = Reline.readmultiline("Question: ", true) do |multiline_input|
    last = multiline_input.split.last
    DONE.include?(last)
  end

  return :noop unless user_message

  lines = user_message.split("\n")
  if lines.size > 1 && DONE.include?(lines.last)
    # remove the "done" from the message
    user_message = lines[0..-2].join("\n")
  end

  return :exit if DONE.include?(user_message.downcase)

  user_message
end

begin
  loop do
    user_message = prompt_for_message

    case user_message
    when :noop
      next
    when :exit
      break
    end

    assistant.add_message_and_run content: user_message, auto_tool_execution: true
    puts assistant.messages.last.content
  end
rescue Interrupt
  exit 0
end