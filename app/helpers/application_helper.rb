# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # XXX option_groups_from_collection_for_selectが使えないか検討する
  def notes_navi_on_header(user, selected="")
    notes = user.accessible(Note)
    head = content_tag("option", _("Jump to Note"), :value=>"")
    notes.group_by(&:category_id).inject(head) do |out, (category_id, notes)|
      options = notes.inject(""){|r,n| r << content_tag("option", n.display_name, :value=>note_path(n)) }
      out << content_tag("optgroup", options, :label => Category.find(category_id).display_name)
    end
  end

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
