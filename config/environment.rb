# Load the Rails application.
require File.expand_path('../application', __FILE__)

local_env = File.join(Rails.root, 'config', 'local_env.rb')
load(local_env) if File.exists?(local_env)

unless Rails.env.test? || Rails.env.ci?
  vars = ['EZID_DEFAULT_SHOULDER',
          'EZID_USER',
          'EZID_PASSWORD',
          'PRODUCTION_URL'].select {|v| ENV[v].blank? }
  if vars.present?
    $stderr.puts "Can't start Rails. Missing critical env variables: #{vars}"
    unless Rails.env.development?
      raise SystemExit.new(1)
    end
  end
end

# Initialize the Rails application.
Rails.application.initialize!

