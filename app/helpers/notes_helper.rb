module NotesHelper
  def has_more?(arr, num = NotesController::DASHBOARD_ITEM_NUM)
    !!arr[num]
  end

  def explain_note(note)
    opts = {
      :name_key => content_tag("span", _("Note|Name") , :class=>"key"),
      :name_val => content_tag("span", note.name , :class=>"val"),
      :publicity_key => content_tag("span", _("Note|Publicity") , :class=>"key"),
      :publicity_val => content_tag("span", publicity_label(note.publicity) , :class=>"val"),
      :category_key => content_tag("span", _("Note|Category") , :class=>"key"),
      :category_val => content_tag("span", note.category.display_name , :class=>"val"),
    }
    _("This note's %{name_key} is `%{name_val}', %{publicity_key} is `%{publicity_val}', and %{category_key} is `%{category_val}'.") % opts
  end

  def explain_users(users)
    spans = users.map{|u| content_tag("span", u.name, :class => "val") }
    user_str = spans.size == 1 ? spans.first : spans[0..-2].join(_(", ")) + _(" and ") + spans.last
    _("%{user_str} are accessible to the note") % {:user_str => user_str }
  end

  def explain_groups(groups)
    spans = groups.map{|g| content_tag("span", g.display_name, :class => "val") }
    group_str = spans[0..-2].join(_(", ")) + _(" and ") + spans.last
    _("%{group_str}'s members are accessible to the note") % {:group_str => group_str }
  end

  def with_last_modified_page(notes, &block)
    ps = Page.last_modified_per_notes(notes.map(&:id))
    ret = notes.map{|note| [note, ps.detect{|p| p.note_id == note.id }] }
    block_given? ? ret.each{|n,p| yield n, p } : ret
  end

  def render_wizard(step, key, &block)
    content_for(key, &block)
    concat render(:partial => "wizard", :locals=>{:step=>step, :key=>key})
  end

  def publicity_label(publicity)
    case publicity
    when Note::PUBLICITY_MEMBER_ONLY then _("Access by member only")
    when Note::PUBLICITY_READABLE    then _("Readable by everyone")
    when Note::PUBLICITY_WRITABLE    then _("Readable/Writable by everyone")
    else raise ArgumentError
    end
  end

  def note_operation(selected)
    options_for_select( [
      [_("menu"), nil],
      [_("new page"), new_note_page_path(current_note)],
      [_("show note"), note_path(current_note)],
      [_("note attachments"), note_attachments_path(current_note)],
    ], selected)
  end
end
