# desc "Explaining what the task does"
# task :skip_embedded do
#   # Task goes here
# end
namespace :skip_embedded do
  namespace :download_thridparty do
    desc "fetch clppy.swf from 'http://github.com/mojombo/clippy/raw/master/build/clippy.swf'"
    task :clippy do
      require 'open-uri'
      source = "http://github.com/mojombo/clippy/raw/master/build/clippy.swf"
      dest   = File.expand_path("public/flash", Rails.root)

      fetch(source, dest)
    end

    private
    def fetch(source, dest, filename_from_url = true)
      if File.directory?(dest) || filename_from_url
        dir, out = dest, File.basename(source)
      else
        dir, out = File.dirname(dest), File.basename(dest)
      end
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      Dir.chdir(dir){ File.open(out, "wb"){|f| f.write open(source).read } }
    end
  end
end
