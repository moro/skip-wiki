namespace :skip_note do
  desc "execute some setup tasks / gems:install db:create db:migrate makemo"
  task :setup => %w[gems:install db:create db:migrate makemo]

  desc "create release .zip archive."
  task :release do
    raise "This directory is not Git repository." unless File.directory?(".git")
    require 'zip/zip'

    commit = ENV["COMMIT"] || "HEAD"
    if tag = ENV["TAG"]
      system(*["git", "tag", tag, commit])
      out = "skip_note-#{tag}.zip"
      commit = tag
    else
      out = Time.now.strftime("skip_note-%Y%m%d%H%M%S.zip")
    end
    commands = ["git", "archive", "--format", "zip", commit]
    File.open(out, "wb") do |f|
      IO.popen(commands.join(" ")){|io| f.write io.read }
    end
    Zip::ZipFile.open(out) do |zs|
      %w[log tmp].each{|d| zs.mkdir d }
      zs.get_output_stream("config/database.yml"){|z| z.write zs.read("config/database.yml.sample") }
    end
  end
end

