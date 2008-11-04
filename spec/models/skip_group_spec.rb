require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SkipGroup do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :display_name => "value for display_name",
      :gid => "value for gid"
    }
  end

  it "should create a new instance given valid attributes" do
    SkipGroup.create!(@valid_attributes)
  end

  describe ".new( <empty> )" do
    before do
      @group = SkipGroup.new
      @group.valid? #=> false
    end

    it "should have errors on :name" do
      @group.should have(1).errors_on(:name)
    end
  end

  describe ".fetch('alice')" do
    before do
      SkipGroup.site = "http://localhost:10080/"
      OpenURI.should_receive(:open_uri).
        with(URI("http://localhost:10080/user/alice/groups.xml")).
        and_return StringIO.new(File.read("spec/fixtures/data/user_groups.xml"))
    end

    it "should have 3 items" do
      SkipGroup.fetch("alice").should have(3).items
    end


    it "and_store.should change SkipGroup.count by 3" do
      lambda{ SkipGroup.fetch_and_store("alice") }.should change(SkipGroup, :count).by(3)
    end

    it "and_store.should return saved SkipGroup instances" do
      SkipGroup.fetch_and_store("alice").should be_all{|o| o.is_a? SkipGroup && !o.new_record? }
    end

    it "2回目は更新だけし、追加はしないこと" do
      SkipGroup.fetch_and_store("alice")
      OpenURI.stub!(:open_uri).and_return StringIO.new(File.read("spec/fixtures/data/user_groups.xml"))
      lambda{ SkipGroup.fetch_and_store("alice") }.should_not change(SkipGroup, :count)
    end
  end
end
