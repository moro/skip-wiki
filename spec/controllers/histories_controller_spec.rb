require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HistoriesController do
  fixtures :notes, :pages
  before do
    @current_note = notes(:our_note)
    controller.stub!(:login_required).and_return(true)
    controller.stub!(:current_note).and_return(@current_note)
  end

  #Delete these examples and add some real ones
  it "should use HistoriesController" do
    controller.should be_an_instance_of(HistoriesController)
  end


  describe "GET 'index'" do
    before do
      @page = pages(:our_note_page_1)
      @current_note.pages.should_receive(:find).with(@page.to_param).and_return(@page)
    end

    it "should be successful" do
      get 'index', :page_id => @page.to_param
      response.should be_success
    end
  end

  describe "GET 'show'" do
    before do
      @page = pages(:our_note_page_1)
      @history = mock_model(History, :revision => 10)

      Page.should_receive(:find).with(@page.to_param, anything()).and_return(@page)
      @page.should_receive(:histories).and_return([@history])

      get 'show', :page_id => @page.to_param, :id => @history.id
    end

    it "should be successful" do
      response.should be_success
    end

    it "@revisionに指定したhistoryのリビジョンが入ること" do
      assigns(:history).should == @history
    end
  end

  describe "GET 'diff'" do
    before do
      @page = pages(:our_note_page_1)
      @page.should_receive(:diff).and_return([0,%w[abc abd]])
      Page.should_receive(:find).with(@page.to_param, anything()).and_return(@page)
    end
    it "should be successful" do
      get 'diff', :page_id => @page.to_param
      response.should be_success
    end
  end
end
