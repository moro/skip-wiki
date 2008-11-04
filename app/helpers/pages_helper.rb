require 'hikidoc'

module PagesHelper
  def group_by_date(pages, col=:updated_at, desc=true)
    ret = pages.group_by{|p| p[col].strftime("%F") }.sort_by{|d,_| d }
    desc ? ret.reverse : ret
  end

  def render_page_content(page, rev=nil)
    case page.format_type
    when "hiki" then render_hiki(page.content(rev))
    when "html" then render_richtext(page.content(rev))
    end
  end

  def render_richtext(content)
    sanitize(content, :attributes=>%w[style])
  end

  def render_hiki(content)
    sanitize(HikiDoc.to_xhtml(content, :level=>2))
  end

  def navi_item(text, path, current_path)
    current = (path == current_path)
    content_tag("li", (current ? {:class=>"current"} : {})) do
      link_to_unless current, text, path
    end
  end
end
