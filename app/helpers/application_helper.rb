# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def icon_tag(icon, desc=nil)
    img = "icons/#{File.basename(icon)}.png"
    if desc
      image_tag(img, :title=>_(desc), :class=>"icon") + _(desc)
    else
      image_tag(img, :title=>icon.humanize, :class=>"icon")
    end
  end

  def javascript_include_file(filename)
    if ::Rails.env == "development"
      fullpath = File.expand_path("public/javascripts/#{filename}.js", ::Rails.root)
      javascript_tag File.read(fullpath)
    else
      javascript_include_tag filename
    end
  end
end
