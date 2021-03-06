class NoteBuilder
  include GetText
  def initialize(user, attrs)
    @user = user
    @attrs = attrs.dup
  end

  def note
    return @note if @note
    @note = Note.new(@attrs) do |note|
              note.owner_group = find_or_initialize_group
              note.accessibilities << Accessibility.new(:group=>note.owner_group)
              note.label_indices << LabelIndex.no_label
            end
  end

  def front_page
    return @page if @page
    @page = returning(Page.front_page) do |page|
              page.edit(Page.front_page_content, @user)
              page.note = note
              page.label_index_id = note.default_label.id
            end
  end

  private
  def find_or_initialize_group
    case @attrs[:group_backend_type]
    when "BuiltinGroup"
      attrs = {:name => @attrs[:name],
               :display_name => _("%{name} group") % {:name=>@attrs[:display_name]},
               :backend=>@user.builtin_groups.build }
      Group.new(attrs){|g| g.memberships = [Membership.new(:group => g, :user=>@user)] }
    when "SkipGroup"
      @user.groups.find(:first, :conditions=>@attrs.slice(:group_backend_type, :group_backend_id))
    end
  end
end
