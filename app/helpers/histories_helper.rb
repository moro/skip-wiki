
module HistoriesHelper
  def link_to_next_diff(histories, a_history, page = @page)
    if a_history == histories.first
      "-"
    else
      pos = histories.index(a_history)
      link_to(_("NEXT"), diff_url(page, histories[pos - 1], a_history))
    end
  end

  def link_to_previous_diff(histories, a_history, page = @page)
    if a_history == histories.last
      "-"
    else
      pos = histories.index(a_history)
      link_to(_("PREV"), diff_url(page, histories[pos + 1], a_history))
    end
  end

  def diff_symbol(symbol, css=true)
    sym = case symbol
          when "=" then ""
          when "-" then "removed"
          when "+" then "added"
          when "!" then "modified"
          end
    css ? sym : sym[0,1].upcase
  end

  def decode_nbsp(string)
    nbsp = [0xA0].pack("U")
    return nbsp if string.blank?
    string.gsub(/&nbsp;/, nbsp)
  end

  private
  def diff_url(page, from, to)
    diff_note_page_histories_path(current_note, page,
                                  {:from => from.revision, :to => to.revision})
  end
end
