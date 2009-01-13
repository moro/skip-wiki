require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::GroupsController do
  fixtures :users
  before do
    controller.stub!(:current_user).and_return(@user = users(:quentin))
    controller.stub!(:require_admin).and_return(true)
  end

  def mock_group(stubs={})
    @mock_group ||= mock_model(Group,stubs)
  end

  def mock_note(stubs={})
    @mock_note ||= mock_model(Note,stubs)
  end

  describe "GET /admin/groups/1" do
    before do
      Group.should_receive(:find).with("7").and_return(mock_group)
      mock_group.should_receive(:owning_note).and_return(mock_note)
      get :show, :id=>"7"
    end

    it "groupが1件取得できること" do
      assigns[:group].should == mock_group
    end

    it "グループオーナーであるノートが1件取得できていること" do
      assigns[:note].should == mock_note
    end
  end

end
