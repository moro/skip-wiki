require 'hikidoc'

module PagesHelper
  def query_form_options(keys = [:keyword, :authors, :label_index_id, :order])
    {:method => "GET",
     :style  => keys.all?{|k| params[k].blank? } ? "display:none" : ""}
  end

  def group_by_date(pages, col=:updated_at, desc=true)
    ret = pages.group_by{|p| p[col].strftime("%F") }.sort_by{|d,_| d }
    desc ? ret.reverse : ret
  end

  def each_with_histories(pages, &block)
    finder_opt = {
      :include => :user,
      :conditions => ["#{History.quoted_table_name}.page_id IN (?)", pages.map(&:id)],
    }
    histories = History.heads.find(:all, finder_opt).inject({}) do |r, history|
      r.update(history.page_id => history)
    end
    pages.each{|page| yield page, histories[page.id] }
  end

  def render_page_content(page, rev=nil)
    case page.format_type
    when "hiki" then render_hiki(page.content(rev))
    when "html" then render_richtext(page.content(rev))
    end
  end

  def render_richtext(content)
    allow = HTML::WhiteListSanitizer.allowed_attributes.dup.add("style")
    sanitize(content, :attributes=>allow)
  end

  def render_hiki(content)
    sanitize(HikiDoc.to_xhtml(content, :level=>2))
  end

  def navi_item(text, path, current_path, *css)
    if path == current_path
      content = h(text)
      css = ["current", *css].join(" ")
    else
      content = link_to(h(text), path)
      css = css.join(" ")
    end

    content_tag("li", content, :class => css)
  end

  def editor_opt(page)
    {
      :basePath => controller.request.relative_url_root + "/javascripts/fckeditor/",
      :height => 450,
      :initialState => page.format_type
    }
  end

  def palette_opt(page)
    {
      :editor => "history_content",
      :note_attachments => note_attachments_path(current_note),
      :page_attachments => note_page_attachments_path(current_note, page),
      :message => {:title => _("Link Palette"),
                   :toggle=> _("toggle"),
                   :insert_link_label => _("Insert Link"),
                   :note_attachments => _("note attachments"),
                   :page_attachments => _("page attachments") }
    }
  end
end
