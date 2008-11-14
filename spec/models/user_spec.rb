# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.

describe User do
  fixtures :users

  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = create_user
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end

    it 'increments User#count' do
      @creating_user.should change(User, :count).by(1)
    end
  end

  describe "#skip_uid=" do
    before do
      @user = create_user
      @user.skip_uid = "alice"
      @user.save!
    end

    it "#skip_account.should_not be_nil" do
      @user.reload.skip_account.should_not be_nil
    end

    it "#skip_uid.should == 'alice'" do
      @user.reload.skip_uid.should == 'alice'
    end
  end

  describe "#skip_uid" do
    before do
      account = Account.new(:login=>"alice", :email=>"alice@example.com")
      account.identity_url = "http://foo.bar/user/alice"
      account.save!
      @user = account.user
    end

    it "#skip_uid.should == 'alice'" do
      @user.skip_account.should be_nil # 念のため
      @user.skip_uid.should == 'alice'
    end
  end

  describe "#build_note" do
    before do
      Page.stub!(:front_page_content).and_return("---FrontPage---")
      @user = create_user
      @note = @user.build_note(
        :name => "value for name",
        :display_name => "value for display_name",
        :description => "value for note description",
        :publicity => 0,
        :category_id => "1",
        :group_backend_type => "BuiltinGroup",
        :group_backend_id => ""
      )
    end

    it "the note should not be_nil" do
      @note.should_not be_nil
    end

    it "the note should be_new_record" do
      @note.should be_new_record
    end

    it "the note.group_backend_type.should == 'BuiltinGroup'" do
      @note.group_backend_type.should == 'BuiltinGroup'
    end

    it "the note.group_backend_type.should == 'value for display_name group'" do
      @note.owner_group.display_name.should == "value for display_name group"
    end

    it "owner_group should be new_record" do
      @note.owner_group.should be_new_record
    end

    describe ".save!" do
      before do
        @note.save!
        @note.reload
      end

      it "should have FrontPage" do
        @note.pages.find_by_name("FrontPage").should_not be_nil
      end

      it "should have accessibility to @note.owner_group" do
        @note.accessibilities.find_by_group_id(@note.owner_group)
      end

      it "'s owner should have membershipsp within @note.owner_group" do
        @user.reload.memberships.find_by_group_id(@note.owner_group_id).should_not be_nil
      end

      it "should accessible the note" do
        @note.owner_group.backend.should_not be_new_record
        @user.accessible(Note).should include(@note)
      end

      it "the note.owner_group.backend.owner.should == @user" do
        @note.owner_group.backend.owner.should == @user
      end
    end

    describe "validation failed" do
      before do
        @note.name = ""
        @note.save #=> false
      end
      it "owner_group.should be_new_record" do
        @note.owner_group.should be_new_record
      end
    end

    describe "(with SQL injection group)" do
      before do
        @note = @user.build_note(
          :name => "value for name",
          :display_name => "value for display_name",
          :publicity => 0,
          :category_id => "1",
          :group_backend_type => "; DELETE * FROM users"
        )
      end

      it "the note should not be valid" do
        @note.should_not be_valid
      end
    end

    describe "#memberships.replace_by_type" do
      fixtures :users
      before do
        @user = create_user(:name=>"alice")
        [
          @skip1 = SkipGroup.create!(:name=>"skip1",:gid=>"skip1"),
          @skip2 = SkipGroup.create!(:name=>"skip2",:gid=>"skip2"),
          @builtin = BuiltinGroup.create!,
        ].each do |backend|
          group = Group.new(:name=>"#{backend.class}_#{backend.id}", :backend=>backend)
          @user.memberships.build(:group => group)
        end

        @user.save!
      end

      describe "BuiltinGroup" do
        before do
          @another = BuiltinGroup.create!
          @user.memberships.replace_by_type(BuiltinGroup, Group.new(:name=>"another", :backend=>@another))
        end
        it "との関連を変更できること" do
          @user.memberships.map{|m| m.group.backend }.should == [@skip1, @skip2, @another]
        end
      end

      describe "SkipGroup" do
        before do
          @another = SkipGroup.create!(:name=>"name", :display_name=>"display_name", :gid=>"hoge")
          @user.memberships.replace_by_type(SkipGroup, Group.new(:name=>"another", :backend=>@another))
        end
        it "との関連を変更できること" do
          @user.memberships.map{|m| m.group.backend }.should == [@builtin, @another]
        end
      end
    end
    describe "#build_skip_membership" do
      # FIXME フィクスチャのセットアップまとめる
      before do
        account = Account.new(:login=>"alice", :email=>"alice@example.com")
        account.identity_url = "http://foo.bar/user/alice"
        account.save!
        @user = account.user

        SkipGroup.should_receive(:fetch_and_store).with("alice").and_return([
          @a_group = SkipGroup.create!(:name=>"a_group", :display_name=>"display_name", :gid=>"a_group"),
          @another = SkipGroup.create!(:name=>"another", :display_name=>"SKIP-Wiki", :gid=>"another")
        ])
        @user.build_skip_membership
      end

      it "SKIPグループとの関連ができること" do
        @user.memberships.map{|m| m.group.backend }.should == [@a_group, @another]
      end

      describe "自動的に作られたグループ" do
        before do
          @created_group = @user.memberships.map(&:group).first
        end

        it "の名前はbackendの + (SKIP)であること" do
          @created_group.display_name.should == @created_group.backend.display_name + "(SKIP)"
        end
      end
    end
  end

protected
  def create_user(options = {})
    record = User.new({:name => "a_user", :display_name => "A User"}.merge(options))
    record.save
    record
  end
end
