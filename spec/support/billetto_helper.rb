# Billetto Test Support
# Configure test environment for Billetto API client

RSpec.configure do |config|
  config.before(:each) do
    # Reset Billetto configuration before each test
    Billetto.instance_variable_set(:@configuration, nil)
  end
end

