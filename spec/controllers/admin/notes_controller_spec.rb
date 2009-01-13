require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::NotesController do
  fixtures :notes
  fixtures :users
  before do
    controller.stub!(:current_user).and_return(@user = users(:quentin))
    controller.stub!(:require_admin).and_return(true)
  end

  def mock_note(stubs={})
    @mock_note ||= mock_model(Note, stubs)
  end

  describe "GET /admin/notes/index" do
    it "Noteが全て取得できていること" do
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

  describe "DELETE /admin/notes/destroy/7" do
    it "noteにdestroyリクエストが飛んでいること" do
      Note.should_receive(:find).with('7').and_return(mock_note)
      mock_note.should_receive(:destroy)
      delete :destroy, :id=>"7"
    end

    it "note一覧画面にリダイレクトされること" do
      Note.should_receive(:find).and_return(mock_note(:destroy=>true))
      delete :destroy, :id=>"1"
      response.should redirect_to(admin_notes_path)
    end
  end

  describe "GET /admin/notes/1" do
    it "noteが１件取得できていること" do
      Note.should_receive(:find).with("1").and_return(mock_note)
      get :show, :id=>"1"
      assigns[:note].should == mock_note
    end
  end

  describe "PUT /admin/notes/1" do
    describe "Noteの更新に成功する場合" do
      it "Note更新のリクエストが送られていること" do
        Note.should_receive(:find).with("7").and_return(mock_note)
        mock_note.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id=>"7", :note=>{'these'=>'params'}
      end

      it "Noteの更新ができていること" do
        Note.stub!(:find).and_return(mock_note(:update_attributes=>true))
        put :update, :id=>"1"
        assigns(:note).should == mock_note
      end

      it "更新後、ノート画面にリダイレクトされること" do
        Note.stub!(:find).and_return(mock_note(:update_attributes=>true))
        put :update, :id=>"1"
        response.should redirect_to(admin_note_path("1"))
      end
    end

    describe "Noteの更新に失敗した場合" do
      it "updateにNote更新のリクエストが飛んでいること" do
        Note.should_receive(:find).with("7").and_return(mock_note)
        mock_note.should_receive(:update_attributes).with({'these'=>'params'})
        put :update, :id=>"7", :note=>{'these'=>'params'}
      end

      it "更新処理が失敗していること" do
        Note.stub!(:find).and_return(mock_note(:update_attributes => false))
        put :update, :id => "7"
        assigns(:note).should equal(mock_note)
      end

      it "編集画面にリダイレクトされること" do
        Note.stub!(:find).and_return(mock_note(:update_attributes => false))
        put :update, :id => "7"
        response.should redirect_to(edit_admin_note_path("7"))
      end
    end
  end

end
