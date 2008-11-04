require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Note do
  before(:each) do
    @user = mock_model(User)
    @group = mock_model(Group)
    @valid_attributes = {
      :name => "value for name",
      :display_name => "value for display_name",
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
end
