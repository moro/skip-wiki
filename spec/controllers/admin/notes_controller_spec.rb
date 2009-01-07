require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::NotesController do
  fixtures :notes
  fixtures :users
  before do
    controller.stub!(:current_user).and_return(@user = users(:quentin))
    controller.stub!(:explicit_user_required).and_return(true)
  end

  def mock_note(stubs={})
    @mock_note ||= mock_model(Note, stubs)
  end

  describe "GET /admin/notes/index" do
    it "全てのノートが取得できていること" do
      Note.should_receive(:find).with(:all).and_return([mock_note])
      get :index
      assigns(:notes).should == [mock_note]
    end
  end

  describe "GET /admin/notes/1/edit" do
    it "should be a select note" do
      Note.should_receive(:find).with("7").and_return(mock_note)
      get :edit, :id => "7"
      assigns(:note).should == mock_note
    end
  end
end
