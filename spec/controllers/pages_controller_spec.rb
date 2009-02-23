require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesController do
  fixtures :notes
  before do
    @current_note = notes(:our_note)
    controller.stub!(:login_required).and_return(true)
    controller.stub!(:current_note).and_return(@current_note)

    @user = mock_model(User)
    @user.stub!(:accessible?).with(@current_note).and_return true
    controller.stub!(:current_user).and_return(@user)
  end

  #Delete this example and add some real ones
  it "should use PagesController" do
    controller.should be_an_instance_of(PagesController)
  end

  describe "GET /notes/hoge/pages/our_note_page_1" do
    fixtures  :pages
    before do
      @page = pages(:our_note_page_1)
      get :show, :note_id=>@current_note.name, :id=>@page.name
    end

    it "statusは200であること" do
      response.code.should == "200"
    end

    it "showテンプレートをrenderしていること" do
      response.should render_template("show")
    end
  end

  describe "GET /notes/hoge/pages/not_exists" do
    fixtures  :pages
    it "responseは404であること" do
      get :show, :note_id=>@current_note.name, :id=>"not_exist"
      response.code.should == "404"
    end
  end

  describe "POST /notes/hoge/pages [SUCCESS]" do
    before do
      page_param = {:name => "page_1", :display_name => "page_1", :format_type => "html", :content => "<p>foobar</p>"}.with_indifferent_access

      @current_note.pages.should_receive(:add).
        with(page_param, @user).and_return(page = mock_model(Page, page_param))
      page.should_receive(:save!).and_return(true)

      post :create, :note_id => @current_note.name, :page => page_param
    end

    it "responseは/notes/our_note/pages/page_1へのリダイレクトであること" do
      response.should redirect_to(note_page_path(@current_note, assigns(:page)))
    end
  end

  describe "POST /notes/hoge/pages [FAILED]" do
    before do
      page_param = {:name => "page_1", :display_name => "page_1", :format_type => "html", :content => "<p>foobar</p>"}.with_indifferent_access

      @current_note.pages.should_receive(:add).
        with(page_param, @user).and_return(page = mock_model(Page, page_param))
      page.should_receive(:save!).and_raise(ActiveRecord::RecordNotSaved)

      post :create, :note_id => @current_note.name, :page => page_param
    end

    it "newテンプレートを表示すること" do
      response.should render_template("new")
    end
  end

  describe "PUT /notes/hoge/pages [SUCCESS]" do
    fixtures :notes
    before do
      page_param = {:published_at => 1.days.since, :name => "page_1", :display_name => "page_1", :format_type => "html", :content => "<p>foobar</p>"}.with_indifferent_access
      @current_note.label_indices << LabelIndex.no_label

      @page = @current_note.pages.add(page_param, @user)
      @page.save!
    end

    it "responseは/notes/our_note/pages/page_01へのリダイレクトであること" do
      put :update, :note_id => @current_note.name, :id =>@page.to_param, :page => {:name => "page_01"}
      response.should redirect_to(note_page_path(@current_note, assigns(:page)))
    end

    it "コンテンツを指定しても無視されること" do
      put :update, :note_id => @current_note.name, :id =>@page.to_param, :page => {:name => "page_01", :content => "new"}
      assigns(:page).content.should == "<p>foobar</p>"
    end

    describe "via XHR" do
      before do
        xhr :put, :update, :note_id => @current_note.name, :id =>@page.to_param, :page => {:display_name => "page_01", :content => "new"}
      end
      it "ページ名が更新されること" do
        assigns(:page).display_name.should == "page_01"
      end

      it "flashが空であること" do
        flash[:notice].should be_blank
      end
    end
  end

  describe "GET /notes/hoge/new" do
    it "作成されるページの公開日時が作成日時に設定されていること" do
      get :new
      assigns(:page).published_at.strftime("%Y-%m-%d").should == Time.now.strftime("%Y-%m-%d")
    end
  end
   
end
