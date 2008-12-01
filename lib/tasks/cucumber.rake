$:.unshift(RAILS_ROOT + '/vendor/plugins/cucumber/lib')
require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = if ENV["FEATURE"]
                      "--format pretty --language ja"
                    else
                      "--format progress --language ja"
                    end
end
task :features => 'db:test:prepare'
