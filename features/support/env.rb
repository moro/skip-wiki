# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'
Cucumber::Rails.use_transactional_fixtures

# Comment out the next line if you're not using RSpec's matchers (should / should_not) in your steps.
require 'cucumber/rails/rspec'

ActionController::Base.class_eval do
  def perform_action
    begin
      perform_action_without_rescue
    rescue Exception => exception
      if handler = handler_for_rescue(exception)
        rescue_action_with_handler(exception)
      else
        raise exception
      end
    end
  end
end

