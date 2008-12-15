require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NotesController do
  fixtures :users
  before do
    controller.stub!(:current_user).and_return(@user = users(:quentin))
    controller.stub!(:explicit_user_required).and_return(true)
  end

  def mock_note(stubs={})
    @mock_note ||= mock_model(Note, stubs)
  end

  describe "responding to GET index" do

    it "should expose all notes as @notes" do
      Note.should_receive(:find).with(:all).and_return([mock_note])
      get :index
      assigns[:notes].should == [mock_note]
    end

    describe "with mime type of xml" do

      it "should render all notes as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Note.should_receive(:find).with(:all).and_return(notes = mock("Array of Notes"))
        notes.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    end

  end

  describe "responding to GET show" do

    it "should expose the requested note as @note" do
      controller.should_receive(:current_note).and_return(mock_note)
      get :show, :id => "37"
      assigns[:note].should equal(mock_note)
    end

    describe "with mime type of xml" do

      it "should render the requested note as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        controller.should_receive(:current_note).and_return(mock_note)
        mock_note.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do

    it "should expose a new note as @note" do
      Note.should_receive(:new).with(:group_backend_type=>"BuiltinGroup").and_return(mock_note)
      get :new
      assigns[:note].should equal(mock_note)
    end

  end

  describe "responding to GET edit" do

    it "should expose the requested note as @note" do
      pending
      @user.groups.should_receive(:find).with("37").and_return(mock_note)
      get :edit, :id => "37"
      assigns[:note].should equal(mock_note)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      before do
        builder = mock("builder")
        NoteBuilder.should_receive(:new).with(@user,{'these' => 'params'}).and_return(builder)
        mock_note.should_receive(:save!)
        builder.should_receive(:note).and_return(mock_note)
        builder.should_receive(:front_page).and_return(mock_model(Page, "save!"=>true))
      end

      it "should expose a newly created note as @note" do
        post :create, :note => {:these => 'params'}
        assigns(:note).should equal(mock_note)
      end

      it "should redirect to the created note" do
        post :create, :note => {:these => 'params'}
        response.should redirect_to(note_page_url(mock_note, "FrontPage"))
      end

    end

    describe "with invalid params" do
      it "@noteに作成失敗したnoteインスタンスが入ること" do
        builder = mock("builder")
        NoteBuilder.should_receive(:new).with(@user,{'these' => 'params'}).and_return(builder)
        mock_note.should_receive(:save!).and_raise ActiveRecord::RecordNotSaved
        builder.should_receive(:note).and_return(mock_note)

        post :create, :note => {:these => 'params'}
        assigns(:note).should equal(mock_note)
      end

      it "editテンプレートを表示すること" do
        builder = mock("builder")
        NoteBuilder.should_receive(:new).with(@user,{}).and_return(builder)
        mock_note.should_receive(:save!).and_raise ActiveRecord::RecordNotSaved
        builder.should_receive(:note).and_return(mock_note)

        post :create, :note => {}
        response.should render_template("edit")
      end
    end
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested note" do
        controller.should_receive(:current_note).and_return(mock_note)
        mock_note.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :note => {:these => 'params'}
      end

      it "should expose the requested note as @note" do
        Note.stub!(:find).and_return(mock_note(:update_attributes => true))
        put :update, :id => "1"
        assigns(:note).should equal(mock_note)
      end

      it "should redirect to the note" do
        Note.stub!(:find).and_return(mock_note(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(note_url(mock_note))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested note" do
        controller.should_receive(:current_note).and_return(mock_note)
        mock_note.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :note => {:these => 'params'}
      end

      it "should expose the note as @note" do
        Note.stub!(:find).and_return(mock_note(:update_attributes => false))
        put :update, :id => "1"
        assigns(:note).should equal(mock_note)
      end

      it "should re-render the 'edit' template" do
        Note.stub!(:find).and_return(mock_note(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested note" do
      Note.should_receive(:find).with("37").and_return(mock_note)
      mock_note.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the notes list" do
      Note.stub!(:find).and_return(mock_note(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(notes_url)
    end

  end

end
