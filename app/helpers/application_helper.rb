# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # XXX option_groups_from_collection_for_selectが使えないか検討する
  def notes_navi_on_header(user, selected="")
    notes = user.accessible(Note)
    head = content_tag("option", _("Jump to Note"), :value=>"")
    notes.group_by(&:category_id).inject(head) do |out, (category_id, notes)|
      options = notes.inject(""){|r,n| r << content_tag("option", n.display_name, :value=>note_page_url(n, "FrontPage")) }
      out << content_tag("optgroup", options, :label => Category.find(category_id).display_name)
    end
  end

  def render_toolbar(current_path)
    ret = content_tag("div", render(:partial => 'pages/user_bar'), :class=>"user-bar")
    if logged_in? && current_note && current_note.accessible?(current_user)
      ret << content_tag("div", render(:partial => "shared/edit_navi", :locals=>{:current_path => current_path}), :class=>"tab")
    end
    return content_tag("div", ret, :class => "toolbar")
  end

  def render_flash(type)
    if message = flash[type]
      content_tag("div", :onclick => "$(this).fadeOut('fast')", :class => type.to_s) do
        content_tag("h3", h(message) + content_tag("span", _("[Click to hide]")))
      end
    end
  end

  def accessible_pages(user = current_user)
    note_ids = user.accessible(Note).map(&:id)
    Page.scoped(:conditions=>["note_id IN (?)", note_ids])
  end

  def date_picker(selector)
    inclusion = javascript_include_tag "jquery/ui/i18n/ui.datepicker-#{locale}.js"
    date_picker_scripts = <<-JS
jQuery(function(){
  jQuery('#{selector}').datepicker(
      jQuery.extend({}, jQuery.datepicker.regional['#{locale}'], #{date_picker_opts.to_json})
  );
})
    JS
    [inclusion, javascript_tag(date_picker_scripts)].join("\n")
  end

  def icon_tag(icon, desc=nil)
    img = "icons/#{File.basename(icon)}.png"
    if desc
      image_tag(img, :title=>_(desc), :class=>"icon") + _(desc)
    else
      image_tag(img, :title=>icon.humanize, :class=>"icon")
    end
  end

  def back_link_to(page_name, url, options ={})
    options[:class] = options[:class].nil? ? "back" :  ["back", options[:class]].flatten.uniq
    link_to(_("Back to %{page}") % {:page => page_name}, url, options)
  end

  def javascript_include_file(filename)
    if ::Rails.env == "development"
      fullpath = File.expand_path("public/javascripts/#{filename}.js", ::Rails.root)
      javascript_tag File.read(fullpath)
    else
      javascript_include_tag filename
    end
  end

  private
  def locale
    GetText.locale
  end

  def date_picker_opts
    { :duration => '',
      :yearRange => '-80:10',
      :showOn => 'both',
      :buttonImage => image_path("jquery/ui.datepicker/calendar.png"),
      :buttonImageOnly => true,
      :dateFormat => "yy-mm-dd" }
  end
end
