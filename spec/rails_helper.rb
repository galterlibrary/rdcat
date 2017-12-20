# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails'

require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

require 'webmock/rspec'

# For front-end testing with phantomjs and poltergeist
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'

require "pundit/rspec"

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app, js_errors: true, inspector: true, phantomjs: Phantomjs.path
  )
end
Capybara.javascript_driver = :poltergeist
Capybara.default_host = 'http://example.com'

require 'shoulda'
require 'factory_girl'
require 'support/factory_girl'

require 'elasticsearch/model'
require 'elasticsearch/extensions/test/cluster'
require 'elasticsearch/extensions/test/startup_shutdown'

require 'carrierwave/test/matchers'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # https://github.com/rails/rails-controller-testing 
  # 
  #      assert_template has been extracted to a gem. To continue using it,
  #              add `gem 'rails-controller-testing'` to your Gemfile.
  [:controller, :view, :request].each do |type|
    config.include ::Rails::Controller::Testing::TestProcess, :type => type
    config.include ::Rails::Controller::Testing::TemplateAssertions, :type => type
    config.include ::Rails::Controller::Testing::Integration, :type => type
  end

  config.include FactoryGirl::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Warden::Test::Helpers, type: :request
  config.include Warden::Test::Helpers, type: :feature
  config.include Capybara::DSL
  config.include CarrierWave::Test::Matchers

  es_config = {
    command: ENV['ELASTIC_SEARCH_EXEC']  || 'elasticsearch',
    port: 9250,
    number_of_nodes: 1,
    timeout: 15,
    network_host: 'localhost'
  }
  # Start an in-memory cluster for Elasticsearch as needed
  #NOTE: This wasn't working with elasticsearch from package manager
  #      on Linux. Tarball from the official page works just fine
  #      but `command' has to be configured as needed.
  config.before :all, elasticsearch: true do
    WebMock.allow_net_connect!
    unless Elasticsearch::Extensions::Test::Cluster.running?(es_config)
      Elasticsearch::Extensions::Test::Cluster.start(es_config)
    end
    WebMock.disable_net_connect!
  end

  # Stop elasticsearch cluster after test run
  config.after :suite do
    WebMock.allow_net_connect!
    if Elasticsearch::Extensions::Test::Cluster.running?(es_config)
      Elasticsearch::Extensions::Test::Cluster.stop(es_config)
    end
    WebMock.disable_net_connect!
  end

  # Create indexes for all elastic searchable models
  config.before :each, elasticsearch: true do
    WebMock.allow_net_connect!
    ActiveRecord::Base.descendants.each do |model|
      if model.respond_to?(:__elasticsearch__)
        begin
          model.__elasticsearch__.create_index!
          model.__elasticsearch__.refresh_index!
        rescue => Elasticsearch::Transport::Transport::Errors::NotFound
        rescue => e
          STDERR.puts "There was an error creating the elasticsearch index for #{model.name}: #{e.inspect}"
        end
      end
    end
  end

  # Delete indexes for all elastic searchable models to ensure clean state between tests
  config.after :each, elasticsearch: true do
    ActiveRecord::Base.descendants.each do |model|
      if model.respond_to?(:__elasticsearch__)
        begin
          model.__elasticsearch__.delete_index!
        rescue => Elasticsearch::Transport::Transport::Errors::NotFound
        rescue => e
          STDERR.puts "There was an error removing the elasticsearch index for #{model.name}: #{e.inspect}"
        end
      end
    end
    WebMock.disable_net_connect!
  end
end
