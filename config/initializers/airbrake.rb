Airbrake.configure do |config|
  config.api_key = ENV['HOPTOAD_API_KEY']
  config.environment_name = Rails.env
end
