module LabelIndicesHelper
  def navigate_in_label(note, page)
    if index = page.label_index
      label_badge = labelize(index)
    else
      index = "none"
      label_badge = content_tag("span", _("No Labels"))
    end

    [ label_badge,
      link_to(h(_"Previous"), prev_note_label_index_path(note, index, :pivot=>page.order_in_label)),
      "|",
      link_to(h(_"Next"), next_note_label_index_path(note, index, :pivot=>page.order_in_label))].join("\n")
  end

  def label_navigation(note, page)
    current = note_label_index_path(note, page.label_index || "none")

    opts = note.label_indices.map{|l| label_option_tag(note, l, current) }
    opts << label_option_tag(note, "none", current)

    select_tag("note_label", opts.join("\n") )
  end

  def label_option_tag(note, label_index, current)
    val = note_label_index_path(note, label_index)
    content_tag("option",
                label_index.is_a?(LabelIndex) ? label_index.display_name : _("No Labels"),
                :value=> val,
                :selected => (val == current))
  end

  def labelize(label_index, link=false, note=nil)
    content = h(label_index.display_name)
    content = link_to content, note_label_index_path(note||label_index.note, label_index) if link
    content_tag("span",
                content,
                :class=>"label_badge",
                :style=>"border-color:%s" % label_index.color)
  end
end
