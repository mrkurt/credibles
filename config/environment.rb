# Load the rails application
require File.expand_path('../application', __FILE__)

if Module.const_defined?(:YAML) && YAML.const_defined?(:ENGINE)
  require 'yaml'
  YAML::ENGINE.yamler= 'syck'
end

# Initialize the rails application
Credibles::Application.initialize!
