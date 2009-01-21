require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::AttachmentsController do
  fixtures :users, :notes

  before do
    controller.stub!(:current_user).and_return(@user = users(:quentin))
    controller.stub!(:require_admin).and_return(true)
  end

  def mock_note(stubs={})
    @mock_note ||= mock_model(Note, stubs)
  end

  def mock_attachment(stubs={})
    @mock_attachment ||= mock_model(Attachment, stubs)
  end

  def mock_attachments(stubs={})
    @mock_attachments ||= (1..3).map {|i| mock_model(Attachment, stubs)}
  end

  describe "POST /admin/notes/our_note/attachments" do
    before do
      controller.stub!(:requested_note).and_return(mock_note)
      mock_note.should_receive(:attachments).and_return(mock_attachments)
    end    

    describe "添付ファイルが正常に保存できる場合" do

      it "生成した添付ファイルが保存できること" do
        mock_attachments.should_receive(:build).and_return(mock_attachment(:save=>true))
        post :create, :note_id=>"our_note"
      end
      it "添付ファイル一覧画面にリダイレクトされること" do
        mock_attachments.should_receive(:build).and_return(mock_attachment(:save=>true))
        post :create, :note_id=>"our_note"
        response.should redirect_to(admin_note_attachments_url(mock_note))        
      end
    end
    describe "添付ファイルが保存に失敗する場合" do
      it "生成した添付ファイルが保存できないこと" do
        mock_attachments.should_receive(:build).and_return(mock_attachment(:save=>false))
        post :create, :note_id=>"our_note"
      end
      it "添付ファイル一覧画面にリダイレクトされること" do
        mock_attachments.should_receive(:build).and_return(mock_attachment(:save=>false))
        post :create, :note_id=>"our_note"
        response.should redirect_to(admin_note_attachments_url(mock_note))
      end
    end
  end 

  describe "DELETE /admin/notes/our_note/attachments/our_attachment" do
    it "添付ファイルにリクエストが飛んでいること" do
      Attachment.should_receive(:find).with("our_attachment").and_return(mock_attachment)
      delete :destroy, :note_id=>"our_note", :id=>"our_attachment"
    end

    it "添付ファイル画面にリダイレクトされること" do
      Attachment.should_receive(:find).with("our_attachment").and_return(mock_attachment(:destroy=>true))
      delete :destroy, :note_id=>"our_note", :id=>"our_attachment"
      response.should redirect_to(admin_note_attachments_url)
    end
  end
 
end
