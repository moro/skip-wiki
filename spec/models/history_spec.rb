require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe History do
  fixtures :pages
  before(:each) do
    @valid_attributes = {
      :page => pages(:our_note_page_1),
      :user_id => "1",
      :revision => "1",
      :content_id => "1"
    }
  end

  it "pageのtimestampを更新すること" do
    @page = pages(:our_note_page_1)
    @page.edit("hoge", mock_model(User))
    @page.save!
    Time.should_receive(:now).at_least(:once).and_return(mock_t = Time.local(2007,12,31, 00, 00, 00))
    History.create!(@valid_attributes) do |h|
      h.page.reload
      h.content = Content.new(:data => "hogehoge")
    end
    @page.reload.updated_at.should == mock_t
  end

  describe ".find_all_by_head_content" do

    def create_history_with_content(page, content)
      History.create(:content => Content.new(:data => content),
                     :page => page,
                     :user => mock_model(User),
                     :revision => History.count.succ)
    end

    before do
      @page = pages(:our_note_page_1)
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

