require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::HistoriesController do
  fixtures :notes, :pages
  before do
    @requested_note = notes(:our_note)
    controller.stub!(:login_required).and_return(true)
    controller.stub!(:require_admin).and_return(true)
    controller.stub!(:requested_note).and_return(@requested_note)
  end
  
  def mock_page(stubs={})
    @mock_page ||= mock_model(Page,stubs)
  end
=begin
  describe "GET /admin/notes/our_note/pages/our_note_page_1/histories/new" do
    it "ページが1件取得できること" do
      Page.should_receive(:find).with("our_note_page_1").and_return(mock_page)
      get :new, :page_id=>"our_note_page_1"
      assigns(:page).should == mock_page
    end
  end
=end
end
