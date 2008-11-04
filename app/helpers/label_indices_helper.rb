module LabelIndicesHelper
  def labelize(label_index, link=false, note=nil)
    content = h(label_index.display_name)
    content = link_to content, note_label_index_path(note||label_index.note, label_index) if link
    content_tag("span",
                content,
                :class=>"label_badge",
                :style=>"border-color:%s" % label_index.color)
  end
end
