require 'haml'
require 'gettext/parser/ruby.rb'

module GetText
  module HamlParser
    @config = { :extnames => ['.haml'] }
    module_function
    def init(config)
      config.each{|k, v| @config[k] = v }
    end

    def parse(file, targets =[])
      lines = Haml::Engine.new(IO.readlines(file).join).precompiled.split(/$/)
      RubyParser.parse_lines(file, lines, targets)
    end

    def target?(file)
      File.extname(file).downcase == ".haml"
    end
  end
end

