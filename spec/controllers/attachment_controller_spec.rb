require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AttachmentsController do
  fixtures :users, :notes
  before do
    controller.stub!(:current_user).and_return(@user = users(:quentin))
    controller.stub!(:current_note).and_return(@note = notes(:our_note))
  end

  describe "GET index.js" do
    before do
      @attachments = [
        @note.attachments.create!(:uploaded_data => fixture_file_upload("data/at_small.png", "image/png", true),
                                  :display_name  => "user iconとかの画像です"),
      ]
      xhr :get, :index, :note_id=>notes(:our_note)
    end

    it do
      response.should be_success
    end

    describe "レスポンスのJSON" do
      before do
        @attachments_json = ActiveSupport::JSON.decode(response.body)
      end

      it do
        @attachments_json.should be_an_instance_of(Array)
      end

      it "最初のデータの[attachment][display_name]は/^user icon/にマッチすること" do
        @attachments_json.first["attachment"]["display_name"].should =~ /^user icon/
      end

      it "最初のデータの[attachment][path]は%r[/notes/our_note/attachments/\d+]にマッチすること" do
        @attachments_json.first["attachment"]["path"].should =~ %r[/notes/our_note/attachments/\d+]
      end

      it "最初のデータの[attachment][inline]がnilでないこと" do
        @attachments_json.first["attachment"]["inline"].should_not be_nil
      end
    end
  end

  describe "DELETE /destroy" do
    before do
      @attachment = @note.attachments.create!(:uploaded_data => fixture_file_upload("data/at_small.png", "image/png", true),
                                              :display_name  => "user iconとかの画像です")
      delete :destroy, :note_id=>notes(:our_note), :id => @attachment.id
    end

    it do
      lambda{ Attachment.find(@attachment) }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it do
      flash[:notice].should_not be_blank
    end
  end

end

