require 'hikidoc'

module PagesHelper
  def fullscreen_action?(note = current_note)
    return true if note.label_navigation_style == LabelIndex::NAVIGATION_STYLE_NONE

    [%w[histories new], %w[pages new] ].any?{|c, a|
      params[:controller] == c && params[:action] == a
    }
  end

  def page_display_name_ipe_option(base={})
    {:messages => {:sending => _("Sending...")}}.merge(base)
  end

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
      :url => {:attachments => note_attachments_url(current_note),
               :pages => note_pages_url(current_note) },
      :messages => {
        :tab => {:insert_link_label => _("Insert Link"),
                 :navi_prev => _("PREV"),
                 :navi_next => _("NEXT")},
        :page_search => {:show_all => _("Show all"),
                         :filter   => _("Filter"),
                         :keyword  => _("Input keyword to search")}
      },
      :uploader => {:target => IframeUploader::UPLOAD_KEY,
                    :trigger => "submit",
                    :src => {:form =>   new_note_attachment_path(current_note, IframeUploader.palette_opt),
                             :target => note_attachments_path(IframeUploader.palette_opt) },
                    :callback => nil }
    }
  end

  def page_operation(selected = request.request_uri)
    common_options = [
      [_("menu"), nil],
      [_("show page"), note_page_path(current_note, @page)],
      [_("edit content"), new_note_page_history_path(current_note, @page)],
      [_("edit page"), edit_note_page_path(current_note, @page)],
      [_("page histories"), note_page_histories_path(current_note, @page)],
    ]
    unless @page.front_page?
      common_options << [_("Delete %{entity}") % {:entity => _("page")}, edit_note_page_path(current_note, @page, :anchor=>"delete")]
    end

    options_for_select(common_options, selected)
  end
end
