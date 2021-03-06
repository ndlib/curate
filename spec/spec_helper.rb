# Configure Rails Environment
ENV["RAILS_ENV"] ||= 'test'

if ENV['COVERAGE']
  require 'simplecov'

  ENGINE_ROOT = File.expand_path('../..', __FILE__)

  # Out of the box, SimpleCov was looking at file in ENGINE_ROOT/spec/internal;
  # After all that was where Rails was pointed at.
  SimpleCov.root(ENGINE_ROOT)
  SimpleCov.start 'rails' do
    filters.clear
    add_filter do |src|
      src.filename !~ /^#{ENGINE_ROOT}/
    end
    add_filter '/spec/'
  end
  SimpleCov.command_name "spec"
end

require File.expand_path("../internal/config/environment.rb",  __FILE__)

require File.expand_path('../matchers', __FILE__)

# Prevent double spec runs under Zeus
require 'rspec/autorun' unless ENV['RUNNING_VIA_ZEUS']

require File.expand_path('../spec_patch', __FILE__)

require 'curate/spec_support'
require 'rspec/active_model/mocks'
require 'database_cleaner'

require 'curate/internal/factories'

Rails.backtrace_cleaner.remove_silencers!

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.fixture_path = File.expand_path("../fixtures", __FILE__)

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.infer_spec_type_from_file_location!

  config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :view
  config.include InputSupport, type: :input, example_group: {
    file_path: 'spec/inputs'
  }

  config.use_transactional_fixtures = false

  config.before(:suite) do
    ActiveFedora::TestCleaner.setup
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    ActiveFedora::TestCleaner.start
    DatabaseCleaner.start
  end

  config.after(:each) do
    ActiveFedora::TestCleaner.clean
    DatabaseCleaner.clean
  end

end
