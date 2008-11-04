#
# Added for Ruby-GetText-Package
#

desc "Create mo-files for L10n"
task :makemo do
  require 'gettext/utils'
  GetText.create_mofiles(true, "po", "locale")
end

desc "Update pot/po files to match new version."
task :updatepo do
  require 'gettext/utils'
  require 'gettext_haml_parser'
  GetText::RGetText.add_parser(HamlParser)
  GetText.update_pofiles("skip-note", Dir.glob("{app,lib}/**/*.{rb,erb,haml}"),
			 "skip-note 0.1.0")
end
