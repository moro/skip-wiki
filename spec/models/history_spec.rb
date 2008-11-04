require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe History do
  before(:each) do
    @valid_attributes = {
      :versionable_id => "1",
      :versionable_type => "value for versionable_type",
      :user_id => "1",
      :revision => "1",
      :content_id => "1"
    }
  end

  it "should create a new instance given valid attributes" do
    History.create!(@valid_attributes)
  end

  describe ".find_all_by_head_content" do
    def current_page; @current_page ||= mock_model(Page) end
    def current_user; @current_user ||= mock_model(User) end

    def create_history_with_content(page, content)
      History.create(:content => Content.new(:data => content),
                     :versionable => page,
                     :user => mock_model(User),
                     :revision => History.count.succ)
    end

    before do
      @page = mock_model(Page)
      @history = create_history_with_content(@page, "hoge hoge hoge")
    end

    it "('hoge').should == [@history]" do
      History.find_all_by_head_content("hoge").should == [@history]
    end

    it "新しい履歴ができると、以前の語ではマッチしなくなること" do
      @history = create_history_with_content(@page, "fuga fuga fuga")
      History.find_all_by_head_content("hoge").should == []
    end
  end
end

