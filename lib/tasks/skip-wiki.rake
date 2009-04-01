namespace :skip_wiki do
  desc "execute some setup tasks / gems:install db:create db:migrate makemo"
  task :setup => %w[gems:install db:create db:migrate makemo]

  desc "build fulltext search cache DIR=[cache_root] SINCE=[sec target updated]"
  task :fulltext_cache do
    require 'skip_note_fulltext_search'
    options = {}
    options[:cache_dir] = ENV["DIR"] unless ENV["DIR"].blank?
    options[:since] = ENV["SINCE"] unless ENV["SINCE"].blank?
    options[:url_prefix] = ENV["URL"] unless ENV["URL"].blank?

    SkipNoteFulltextSearch.run(options)
  end

  desc "create release .zip archive."
  task :release do
    raise "This directory is not Git repository." unless File.directory?(".git")
    require 'zip/zip'
    require 'fileutils'

    commit = ENV["COMMIT"] || "HEAD"
    if tag = ENV["TAG"]
      system(*["git", "tag", tag, commit])
      out = "skip-wiki-#{tag}"
      commit = tag
    else
      out = Time.now.strftime("skip-wiki-%Y%m%d%H%M%S")
    end
    FileUtils.mkdir_p "pkg/#{out}"
    system("git archive --format tar #{commit} | tar xvf - -C pkg/#{out}")
    Dir.chdir("pkg/#{out}") do
      %w[log tmp].each{|d| Dir.mkdir d }
      FileUtils.cp "config/database.yml.sample", "config/database.yml"
      system("rake rails:freeze:gems VERSION=2.1.2")
      system("rake gems:unpack:dependencies")
    end
    Dir.chdir("pkg") do
      system("zip #{out}.zip #{out}")
      FileUtils.rm_rf out
    end
  end
end

