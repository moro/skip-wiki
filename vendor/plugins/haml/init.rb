if config.respond_to?(:gems)
  config.gem 'haml', :version => '>=2.0.4'
else
  begin
    require File.join(File.dirname(__FILE__), 'lib', 'haml') # From here
  rescue LoadError
    require 'haml' # From gem
  end
end

# Load Haml and Sass
config.to_prepare do
  Haml.init_rails(binding)
end
