require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MembershipsController do

  #Delete this example and add some real ones
  it "should use MembershipsController" do
    controller.should be_an_instance_of(MembershipsController)
  end

  describe "GET /users/alice/memberships" do
    before do
      @alice = mock_model(User)
      @alice.should_receive(:memberships).
        and_return([mock_model(Membership), mock_model(Membership)])
      User.should_receive(:find).with("alice").and_return(@alice)
      get :index, :user_id=>"alice"
    end

    it { response.should be_success }
  end

  describe "POST /users/:user_id/memberships/skip" do
    fixtures :users

    before do
      @user = users(:quentin)
      controller.stub!(:current_user).and_return(@user)
      @user.should_receive(:build_skip_membership).and_return(true)

      post :skip, :user_id => @user.name, :skip_uid=>"quantin"
    end

    it "should generates params for membership skip" do
      params_from(:post, '/users/alice/memberships/skip').should ==
        {:controller => 'memberships', :action => 'skip', :user_id=>"alice"}
    end
  end

  describe "POST /groups/1/memberships" do
    fixtures :users, :groups

    before do
      @user = users(:quentin)
      @group = groups(:group_1)
      @user.groups.should_receive(:find).with(@group.id.to_s).and_return(@group)

      controller.stub!(:current_user).and_return(@user)

      @post_request = lambda do
        post :create, :group_id => @group.id,
                      "memberships"=>[[@user.id,{:group_id=>@group.id, :user_id=>@user.id, :enabled=>"1"}],
                                      ["4",     {:group_id=>@group.id, :user_id=>"4"}]]
      end
    end

    it "current_userは外せないこと" do
      other_user = users(:aaron)
      @group.should_receive(:user_ids=).with([other_user.id, @user.id])
      post :create, :group_id => @group.id,
                    "memberships"=>[[other_user.id, {:group_id=>@group.id, :user_id=>other_user.id, :enabled=>"1"}],
                                    [@user.id,      {:group_id=>@group.id, :user_id=>@user.id}],
                                    ["4" ,          {:group_id=>@group.id, :user_id=>"4"} ]]
    end

    it do
      @post_request.call
      response.should redirect_to(group_path(@group))
    end

    it "Membershipが追加したぶん(1つ)増えること" do
      @post_request.should change(Membership, :count).by(1)
    end

    describe "[FAILURE]" do
      fixtures :users, :groups

      before do
        @group.should_receive(:user_ids=).and_raise(ActiveRecord::RecordNotSaved)

        post :create, :group_id => @group.id,
                      "memberships"=>[["1",{:group_id=>@group.id, :user_id=>"1", :enabled=>"1"}],
                                      ["4",{:group_id=>@group.id, :user_id=>"4"}]]
      end

      it do
        response.should render_template("groups/show")
      end
    end
  end
end
