require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe FulltextSearchCache::PartialLoader, "new(mock_note, 100)", :type => :model do
  before do
    @klass = mock("mock_note")
    @klass.should_receive(:count).and_return 101
    @klass.should_receive(:find).with(:all, :limit => 100, :offset => 0).and_return((1..99).to_a)
    @klass.should_receive(:find).with(:all, :limit => 100, :offset => 100).and_return [100, 101]

    @loader = FulltextSearchCache::PartialLoader.new(@klass, 100)
  end

  it do
    mock_block = mock("block")
    mock_block.should_receive(:call).exactly(101).times
    @loader.each{|n| mock_block.call }
  end
end

