module NotesHelper
  def with_last_modified_page(notes, &block)
    ps = Page.last_modified_per_notes(notes.map(&:id))
    ret = notes.map{|note| [note, ps.detect{|p| p.note_id == note.id }] }
    block_given? ? ret.each{|n,p| yield n, p } : ret
  end

  def render_wizard(step, key, &block)
    content_for(key, &block)
    concat render(:partial => "wizard", :locals=>{:step=>step, :key=>key})
  end
end
