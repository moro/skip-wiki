require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HistoriesController do
  fixtures :notes, :pages
  before do
    @current_note = notes(:our_note)
    @user = mock_model(User)

    controller.stub!(:current_user).and_return(@user)
    controller.stub!(:current_note).and_return(@current_note)

    @user.stub!(:page_editable?).with(@current_note).and_return true
  end

  #Delete these examples and add some real ones
  it "should use HistoriesController" do
    controller.should be_an_instance_of(HistoriesController)
  end


  describe "GET 'index'" do
    before do
      @page = pages(:our_note_page_1)
      @current_note.pages.should_receive(:find_by_name).with(@page.to_param).and_return(@page)
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

      Page.should_receive(:find_by_name).with(@page.to_param).and_return(@page)
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
      Page.should_receive(:find_by_name).with(@page.to_param, anything()).and_return(@page)
    end
    it "should be successful" do
      get 'diff', :page_id => @page.to_param
      response.should be_success
    end
  end

  describe "xhr POST create" do
    before do
      @user = mock_model(User)
      @page = pages(:our_note_page_1)
      controller.should_receive(:current_user).at_least(:once).and_return(@user)

      xhr :post, :create, :page_id => @page.to_param, :history => {:content => "hogehoge"}
    end

    it "response should be redirect" do
      response.should be_success
    end

    it "response.headers['Location'] should not be blank" do
      response.headers['Location'].should_not be_blank
    end
  end

  describe "xhr PUT update" do
    before do
      @user = mock_model(User)
      @page = pages(:our_note_page_1)
      controller.should_receive(:current_user).at_least(:once).and_return(@user)

      @history = @page.edit("hogehoge", @user)
      @history.save
      @rev = @page.revision

      @req = lambda{
        xhr :put, :update, :page_id => @page.to_param,
                           :id => @history.to_param, :history => {:content => "fugafuga"}
      }
    end

    it "response should be redirect" do
      @req.call
      response.should be_success
    end

    it "もとのhistoryが更新されていること" do
      @req.call
      @history.reload.content.data.should == "fugafuga"
    end

    it "revisionが変わっていないこと" do
      @req.should_not change(@page, :revision)
    end
    it "Contentの数が変わっていないこと" do
      @req.should_not change(Content, :count)
    end
    it "Historyの数が変わっていないこと" do
      @req.should_not change(History, :count)
    end
  end
end
