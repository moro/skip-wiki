module Admin::ApplicationHelper

  def admin_operation(sym,selected)
    menu = if sym == :entire
             entire_menu
           elsif sym == :note
             note_menu
           elsif sym == :note_and_page
             note_and_page_menu
           end
    options_for_select(menu,selected)
  end

protected
  def entire_menu
    [
      [_("menu"), nil],
      [_("manage users"), admin_users_path],
      [_("manage notes"), admin_notes_path]
    ]
  end

  def note_menu
    [
      [_("menu"), nil],
      [_("manage pages"), admin_note_pages_path(@note)],
      [_("manage attachments"), admin_note_attachments_path(@note)],     
      [_("User|Notes"), admin_notes_path]
    ]
  end

  def note_and_page_menu
    note_menu.push([_("manage property"), edit_admin_note_page_path(@note,@page)]).
              push([_("manage page"), new_admin_note_page_history_path(@note,@page)]) 
  end
end
