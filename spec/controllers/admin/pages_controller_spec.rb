require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::PagesController do
  fixtures :users
  fixtures :notes
  fixtures :pages

  before do
    @current_note = notes(:our_note)
    @page = pages(:our_note_page_1)
    controller.stub!(:current_user).and_return(@user = users(:quentin))
    controller.stub!(:login_required).and_return(true)
    controller.stub!(:require_admin).and_return(true)
    controller.stub!(:current_note).and_return(@current_note)
  end

  def mock_page(stubs={})
    @mock_page ||= mock_model(Page, stubs)
  end

  def mock_note(stubs={})
    @mock_note ||= mock_model(Note, stubs)
  end

  # TODO 絞り込み一覧を追加したためテスト書くのが難しくなった
  describe "GET /notes/our_note/pages" do
    it "our_noteのページ一覧が全て取得できていること" do
      pending
      Page.should_receive(:admin).with(@current_note.id).and_return([mock_page])
      get :index, :note_id=>@current_note.name
      assigns(:pages).should == [mock_page]
    end
  end

  describe "GET /notes/our_note/pages/our_note_page_1" do
    before do
      controller.should_receive(:requested_note).and_return(mock_note)
      get :show, :id=>@page.name, :note_id=>@current_note.name
    end

    it "our_noteのour_note_page_1が取得できていること" do
      assigns(:page).should == @page
    end

    it "our_note_page_1のノートが取得できていること" do
      assigns(:note).should == mock_note
    end
  end

  describe "DELETE /admin/our_note/pages/our_note_page_1" do
    it "pageにdestroyリクエストが飛んでいること" do
      Page.should_receive(:find).with("7").and_return(mock_page)
      mock_page.should_receive(:destroy)
      delete :destroy, :id=>"7"
    end

    it "ページ一覧画面にリダイレクトされること" do
      controller.should_receive(:requested_note).and_return(@current_note)
      Page.should_receive(:find).and_return(mock_page(:destroy=>true))
      delete :destroy, :id=>"7", :note_id=>@current_note
      response.should redirect_to(admin_note_pages_path(@current_note))
    end
  end

  describe "GET /admin/notes/our_note/pages/out_note_page_1/edit" do
    it "対象ページが１件取得できること" do
      Page.should_receive(:find).with("our_note_page_1").and_return(mock_page)
      get :edit, :id=>"our_note_page_1", :note_id=>@current_note
      assigns(:page).should == mock_page
    end
  end

  describe "PUT /admin/notes/our_note/pages/our_note_page_1" do
    describe "ページの更新に成功する場合" do
      it "ページ更新のリクエストが送られていること" do
        Page.should_receive(:find).with("our_note_page_1").and_return(mock_page)
        mock_page.should_receive(:update_attributes).with({'these'=>'params'})
        put :update, :id=>"our_note_page_1", :note_id=>"our_note", :page=>{'these'=>'params'}
      end

      it "ページの更新が成功すること" do
        Page.stub!(:find).and_return(mock_page(:update_attributes=>true))
        put :update, :id=>"our_note_page_1", :note_id=>"our_note"
        assigns(:page).should == mock_page
      end

      it "更新後、ページ一覧画面にリダイレクトされること" do
        Page.stub!(:find).and_return(mock_page(:update_attributes=>true))
        put :update, :id=>"our_note_page_1", :note_id=>@current_note
        response.should redirect_to(admin_note_page_path(@current_note,mock_page))
      end
    end

    describe "ページの更新に失敗する場合" do
      it "ページ更新のリクエストが送られていること" do
        Page.should_receive(:find).with("our_note_page_1").and_return(mock_page)
        mock_page.should_receive(:update_attributes).with({'these'=>'params'})
        put :update, :id=>"our_note_page_1", :note_id=>"our_note", :page=>{'these'=>'params'}
      end

      it "編集画面にリダイレクトされること" do
        Page.stub!(:find).and_return(mock_page(:update_attributes=>false))
        put :update, :id=>"our_note_page_1", :note_id=>@current_note
        response.should redirect_to(edit_admin_note_page_path(@current_note,mock_page))
      end

    end  
  end
end
