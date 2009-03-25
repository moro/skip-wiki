$:.unshift(RAILS_ROOT + '/vendor/plugins/cucumber/lib')
gem 'cucumber', '=0.1.16'
require 'cucumber/rake/task'

task :features => 'db:test:prepare'
desc "Run all features"
task :features => "features:all"
task :features => 'db:test:prepare'
require 'cucumber/rake/task' #I have to add this -mischa

namespace :features do
  Cucumber::Rake::Task.new(:all) do |t|
    t.cucumber_opts = if ENV["FEATURE"]
                        "--format pretty --language ja"
                      else
                        "--format progress --language ja"
                      end
  end
=begin
  Cucumber::Rake::Task.new(:cruise) do |t|
    t.cucumber_opts = "--format pretty --out=#{ENV['CC_BUILD_ARTIFACTS']}/features.txt --format html --out=#{ENV['CC_BUILD_ARTIFACTS']}/features.html" 
    t.rcov = true
    t.rcov_opts = %w{--rails --exclude osx\/objc,gems\/,spec\/}
    t.rcov_opts << %[-o "#{ENV['CC_BUILD_ARTIFACTS']}/features_rcov"]
  end
=end
  Cucumber::Rake::Task.new(:rcov) do |t|
    t.cucumber_opts = "--format progress --language ja"
    t.rcov = true
    t.rcov_opts = IO.readlines(File.join('spec', 'rcov.opts')).map {|line| line.chomp.split(" ") }.flatten
    t.rcov_opts << %[-o "coverage/features"]
  end
end


namespace :coverage do
  desc "delete aggregate coverage data"
  task(:clean) {
    rm_f "coverage/*"
    mkdir "coverage" unless File.exist? "coverage"
    rm "coverage/aggregate.rcov" if File.exist? "coverage/aggregate.rcov"
  }
end

desc "all coverage"
task :coverage => ["coverage:clean","spec:rcov", "features:rcov"]

