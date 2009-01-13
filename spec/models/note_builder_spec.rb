require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NoteBuilder do
  fixtures :users
  before do
    attrs = {
        :name => "value for name",
        :display_name => "value for display_name",
        :description => "value for note description",
        :publicity => 0,
        :category_id => "1",
        :group_backend_type => "BuiltinGroup",
        :group_backend_id => ""
    }
    @builder = NoteBuilder.new(users(:quentin), attrs)
    @note = @builder.note
  end

  it "the note should be_new_record" do
    @note.should be_new_record
  end

  it "the note.group_backend_type.should == 'BuiltinGroup'" do
    @note.group_backend_type.should == 'BuiltinGroup'
  end

  it "the note.group_backend_type.should == 'value for display_name group'" do
    @note.owner_group.display_name.should == "value for display_name group"
  end

  it "owner_group should be new_record" do
    @note.owner_group.should be_new_record
  end

  describe "保存前のfront_page" do
    it "はnew_recordであること" do
      @builder.front_page.should be_new_record
    end

    it "のnoteは@noteであること" do
      @builder.front_page.should be_new_record
    end
  end

  describe "validation failed" do
    before do
      @note.name = ""
      @note.save #=> false
    end
    it "owner_group.should be_new_record" do
      @note.owner_group.should be_new_record
    end
  end

  describe "#save!" do
    before do
      @note.save!
      @user = users(:quentin)
      @note.reload
    end

    it "should have accessibility to @note.owner_group" do
      @note.accessibilities.find_by_group_id(@note.owner_group)
    end

    it "'s owner should have membershipsp within @note.owner_group" do
      @user.reload.memberships.find_by_group_id(@note.owner_group_id).should_not be_nil
    end

    it "should accessible the note" do
      @note.owner_group.backend.should_not be_new_record
      @user.accessible_or_public_notes.should include(@note)
    end

    it "the note.owner_group.backend.owner.should == @user" do
      @note.owner_group.backend.owner.should == @user
    end

    it "should have(1) label_indices" do
      @note.should have(1).label_indices
    end

    it "front_pageはまだnew_recordであること" do
      @builder.front_page.should be_new_record
    end

    describe "保存後のfront_page" do
      before do
        @builder.front_page.save!
        @builder.front_page.reload
      end

      it "noteとの関連も保存されること" do
        @builder.front_page.note.should == @note
      end

      it "デフォルトラベルに紐づいていること" do
        @builder.front_page.label_index.should == @note.default_label
      end
    end
  end
end
