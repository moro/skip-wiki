require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Note do
  before(:each) do
    @user = mock_model(User)
    @group = mock_model(Group)
    @valid_attributes = {
      :name => "value for name",
      :display_name => "value for display_name",
      :description => "value for description.",
      :publicity => Note::PUBLICITY_MEMBER_ONLY,
      :deleted_on => Time.now,
      :category_id => "1",
      :owner_group => @group
    }
  end

  it "should create a new instance given valid attributes" do
    Note.create!(@valid_attributes)
  end

  it "shoud have accesibility to owner group" do
    Note.create(@valid_attributes).reload.
      should have(1).accessibilities
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
    before(:each) do
      @note = Note.create(@valid_attributes)
      @user = mock_model(User)
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
  end

  describe "build_front_page" do
    before(:each) do
      Page.should_receive(:front_page_content).and_return("---FrontPage---")
      @note = Note.new(@valid_attributes)
      @user = mock_model(User)
      @page = @note.build_front_page(@user)
      @note.save!
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
  end
end
