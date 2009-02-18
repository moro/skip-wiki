require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Note do
  fixtures :users
  before(:each) do
    @user = users(:quentin)
    @group = mock_model(Group)
    @valid_attributes = {
      :name => "value for name",
      :display_name => "value for display_name",
      :description => "value for description.",
      :publicity => Note::PUBLICITY_MEMBER_ONLY,
      :deleted_on => Time.now,
      :category_id => "1",
      :owner_group => @group,
      :group_backend_type => "BuiltinGroup",
    }
  end

  it "should create a new instance given valid attributes" do
    Note.create!(@valid_attributes)
  end

  describe ".fulltext" do
    fixtures :notes
    it "'Our' should hit 1 notes" do
      Note.fulltext("Our").should have(1).items
    end

    it "'description' should hit 2 notes" do
      Note.fulltext("description").should have(2).items
    end

    it "'--none--' should hit 0 notes" do
      Note.fulltext("--none--").should have(0).items
    end

    it "(nil) should hit 2 notes" do
      Note.fulltext(nil).should have(2).items
    end
  end

  describe "pages.add(attrs, user)" do
    fixtures :users
    before(:each) do
      @note = NoteBuilder.new(@user, @valid_attributes).note
      @note.save!
      @initialize_attrs = {
        :name=>"FrontPage",
        :display_name => "トップページ",
        :format_type => "hiki",
        :content => "hogehogehoge",
      }

      @page = @note.pages.add(@initialize_attrs, @user)
    end

    it "create new page" do
      @page.save!
      @note.reload.should have(1).pages
    end

    it "do not create untill @page.save" do
      @note.reload.should have(0).pages
    end

    it "作成されたページのLabelIndexがデフォルトラベルであること" do
      @page.save!
      @page.reload.label_index.should == @note.default_label
    end
  end

  describe "build_front_page" do
    before(:each) do
      Page.should_receive(:front_page_content).and_return("---FrontPage---")
      builder = NoteBuilder.new(@user, @valid_attributes)
      @note = builder.note
      @page = builder.front_page

      @note.save!
      @page.save!
    end

    it "create new page" do
      @note.reload.should have(1).pages
    end

    it "ページのnameはFrontPageであること" do
      page = @note.reload.pages.first
      page.name.should == "FrontPage"
    end

    it "ページのcontentsは指定したものであること" do
      page = @note.reload.pages.first
      page.content.should == "---FrontPage---"
    end

    describe "#destroy" do
      before do
        @note.destroy
      end

      it{ Page.find_all_by_note_id(@note).should be_empty }
    end
  end

  describe "accessible?" do
    before(:each) do
      @note = @user.build_note(
        :name => "value for name",
        :display_name => "value for display_name",
        :description => "value for note description",
        :publicity => Note::PUBLICITY_READABLE,
        :category_id => "1",
        :group_backend_type => "BuiltinGroup",
        :group_backend_id => ""
      )
      @note.save!
    end

    it "グループのユーザはaccessibleであること" do
      users(:quentin).should be_accessible(@note)
    end

    it "グループ外のユーザはaccessibleでないこと" do
      users(:aaron).should_not be_accessible(@note)
    end
  end

  def build_note
    @user.build_note(
      :name => "value for name",
      :display_name => "value for display_name",
      :description => "value for note description",
      :publicity => Note::PUBLICITY_READABLE,
      :category_id => "1",
      :group_backend_type => "BuiltinGroup",
      :group_backend_id => ""
    )
  end
end
