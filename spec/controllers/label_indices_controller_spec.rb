require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LabelIndicesController do
  def mock_label_index(stubs={})
    @mock_label_index ||= mock_model(LabelIndex, stubs)
    @mock_label_index.stub!(:display_name).and_return("Display name")
    @mock_label_index
  end
  fixtures :notes

  before do
    @note = mock_model(Note)#notes(:our_note)
    controller.should_receive(:login_required).and_return(true)
    controller.should_receive(:current_note).at_least(:once).and_return(@note)
  end

  describe "responding to GET index" do
    it "should expose all label_indices as @label_indices" do
      @note.should_receive(:label_indices).and_return([mock_label_index])
      get :index
      assigns[:label_indices].should == [mock_label_index]
    end

    describe "with mime type of xml" do
      it "should render all label_indices as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @note.should_receive(:label_indices).and_return(label_indices = mock("Array of LabelIndices"))
        label_indices.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    end

  end

  describe "responding to GET show" do

    it "should expose the requested label_index as @label_index" do
      @note.should_receive(:label_indices).and_return(LabelIndex)
      LabelIndex.should_receive(:find).with("37").and_return(mock_label_index)
      get :show, :id => "37"
      assigns[:label_index].should equal(mock_label_index)
    end

    describe "with mime type of xml" do

      it "should render the requested label_index as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @note.should_receive(:label_indices).and_return(LabelIndex)
        LabelIndex.should_receive(:find).with("37").and_return(mock_label_index)
        mock_label_index.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
  end

  describe "responding to POST create" do

    describe "with valid params" do
      before do
        @note.should_receive(:label_indices).and_return(proxy = mock("proxy"))
        proxy.should_receive(:build).with({'these' => 'params'}).and_return(mock_label_index(:save => true))
      end

      it "should expose a newly created label_index as @label_index" do
        post :create, :label_index => {:these => 'params'}
        assigns(:label_index).should equal(mock_label_index)
      end

      it "should redirect to the created label_index" do
        post :create, :label_index => {:these => 'params'}
        response.should redirect_to(note_url(@note))
      end
    end

    describe "with valid params via Ajax" do
      before do
        @note.should_receive(:label_indices).and_return(proxy = mock("proxy"))
        m = mock_label_index(:save => true)
        m.should_receive(:to_json).and_return("--- JSON ---")
        proxy.should_receive(:build).with({'these' => 'params'}).and_return(m)
      end

      it "should expose a newly created label_index as @label_index" do
        xhr :post, :create, :label_index => {:these => 'params'}
        assigns(:label_index).should equal(mock_label_index)
      end

      it "should redirect to the created label_index" do
        xhr :post, :create, :label_index => {:these => 'params'}
        response.code.should == "201"
      end
    end


    describe "with invalid params" do
      before do
        @note.should_receive(:label_indices).and_return(proxy = mock("proxy"))
        proxy.should_receive(:build).with({'these' => 'params'}).and_return(mock_label_index(:save => false))
      end

      it "should expose a newly created but unsaved label_index as @label_index" do
        post :create, :label_index => {:these => 'params'}
        assigns(:label_index).should equal(mock_label_index)
      end

      it "should re-render the 'new' template" do
        post :create, :label_index => {:these => 'params'}
        response.should render_template('new')
      end
    end
  end

  describe "responding to PUT udpate" do
    before do
      @note.should_receive(:label_indices).and_return(proxy = mock("proxy"))
      proxy.should_receive(:find).with("37").and_return(mock_label_index)
    end

    describe "with valid params" do
      before do
        mock_label_index.should_receive(:update_attributes).with({'these' => 'params'}).and_return(true)
      end
      it "should expose the requested label_index as @label_index" do
        put :update, :id => "37", :label_index => {:these => 'params'}
        assigns(:label_index).should equal(mock_label_index)
      end

      it "should redirect to the label_index" do
        put :update, :id => "37", :label_index => {:these => 'params'}
        response.should redirect_to(note_label_indices_url(@note))
      end

    end

    describe "with invalid params" do
      before do
        mock_label_index.should_receive(:update_attributes).with({'these' => 'params'}).and_return(false)
        put :update, :id => "37", :label_index => {:these => 'params'}
      end

      it "should expose the label_index as @label_index" do
        assigns(:label_index).should equal(mock_label_index)
      end

      it "should re-render the 'edit' template" do
        response.should render_template('index')
      end
    end
  end

  describe "responding to DELETE destroy" do
    before do
      @note.should_receive(:label_indices).and_return(proxy = mock("proxy"))
      proxy.should_receive(:find).with("37").and_return(mock_label_index)
      mock_label_index.should_receive(:destroy).and_return(true)
    end

    it "should redirect to the label_indices list" do
      delete :destroy, :id => "37"
      response.should redirect_to(note_label_indices_url(@note))
    end
  end
end

describe LabelIndicesController, "[through]" do
  before do
    @note = notes(:our_note)
    controller.should_receive(:login_required).and_return(true)
    controller.should_receive(:current_note).at_least(:once).and_return(@note)
  end

  describe "responding to GET next [through]" do
    fixtures :notes, :pages
    before do
      @label = LabelIndex.create!(:display_name=>"label", :note=>@note)
      (@p1 = pages(:our_note_page_1)).label_index = @label
      (@p2 = pages(:our_note_page_2)).label_index = @label
    end

    describe "[success]" do
      before do
        get :next, :note_id => @note.name, :id => @label.id, :pivot=>@p1.label_indexings.first.page_order
      end
      it do response.should be_redirect ;end
      it "assigns(:page)はp2であること" do
        assigns(:page).should == @p2
      end
    end

    describe "[failure]" do
      before do
        request.env["HTTP_REFERER"] = "/"
        get :next, :note_id => @note.name, :id => @label.id, :pivot=>@p2.label_indexings.first.page_order
      end
      it do response.should be_redirect ;end
      it do flash[:notice].should_not be_blank ;end
      it "assigns(:page)はnilであること" do assigns(:page).should be_nil ;end
    end
  end

  describe "responding to GET prev [through][success]" do
    fixtures :notes, :pages
    before do
      @label = LabelIndex.create!(:display_name=>"label", :note=>@note)
      (@p1 = pages(:our_note_page_1)).label_index = @label
      (@p2 = pages(:our_note_page_2)).label_index = @label
      get :prev, :note_id => @note.name, :id => @label.id, :pivot=>@p2.label_indexings.first.page_order
    end

    it do response.should be_redirect ;end
    it "assigns(:page)はp1であること" do
      assigns(:page).should == @p1
    end
  end
end
