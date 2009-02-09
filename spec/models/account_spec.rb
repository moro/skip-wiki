# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe Account do
  fixtures :accounts

  describe 'being created' do
    before do
      @account = nil
      @creating_account = lambda do
        @account = create_account
        violated "#{@account.errors.full_messages.to_sentence}" if @account.new_record?
      end
    end

    it 'increments Account#count' do
      @creating_account.should change(Account, :count).by(1)
    end
  end

  #
  # Validations
  #

  describe 'allows legitimate logins:' do
    ['123', '1234567890_234567890_234567890_234567890',
     'hello.-_there@funnychar.com'].each do |login_str|
      it "'#{login_str}'" do
        lambda do
          u = create_account(:login => login_str)
          u.errors.on(:login).should     be_nil
        end.should change(Account, :count).by(1)
      end
    end
  end
  
  describe 'allows legitimate emails:' do
    ['foo@bar.com', 'foo@newskool-tld.museum', 'foo@twoletter-tld.de', 'foo@nonexistant-tld.qq',
     'r@a.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail.com',
     'hello.-_there@funnychar.com', 'uucp%addr@gmail.com', 'hello+routing-str@gmail.com',
     'domain@can.haz.many.sub.doma.in', 'student.name@university.edu'
    ].each do |email_str|
      it "'#{email_str}'" do
        lambda do
          u = create_account(:email => email_str)
          u.errors.on(:email).should     be_nil
        end.should change(Account, :count).by(1)
      end
    end
  end

  describe 'allows legitimate names:' do
    ['Andre The Giant (7\'4", 520 lb.) -- has a posse',
     '', '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890',
    ].each do |name_str|
      it "'#{name_str}'" do
        lambda do
          u = create_account(:name => name_str)
          u.errors.on(:name).should     be_nil
        end.should change(Account, :count).by(1)
      end
    end
  end

  #
  # Authentication
  #

  it 'sets remember token' do
    accounts(:quentin).remember_me
    accounts(:quentin).remember_token.should_not be_nil
    accounts(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    accounts(:quentin).remember_me
    accounts(:quentin).remember_token.should_not be_nil
    accounts(:quentin).forget_me
    accounts(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    accounts(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    accounts(:quentin).remember_token.should_not be_nil
    accounts(:quentin).remember_token_expires_at.should_not be_nil
    accounts(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    accounts(:quentin).remember_me_until time
    accounts(:quentin).remember_token.should_not be_nil
    accounts(:quentin).remember_token_expires_at.should_not be_nil
    accounts(:quentin).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    accounts(:quentin).remember_me
    after = 2.weeks.from_now.utc
    accounts(:quentin).remember_token.should_not be_nil
    accounts(:quentin).remember_token_expires_at.should_not be_nil
    accounts(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  describe ".fulltext" do
    it "'quen'で検索すると1件該当すること" do
      Account.fulltext("quen").should have(1).items
    end

    it "'example'で検索すると3件該当すること" do
      Account.fulltext("example").should have(3).items
    end

    it "'--none--'で検索すると0件該当すること" do
      Account.fulltext("--none--").should have(0).items
    end

    it "(nil)で検索すると3件該当すること" do
      Account.fulltext(nil).should have(3).items
    end
  end

protected
  def create_account(options = {})
    u = User.create(:name => 'quire', :display_name => 'quire')
    u.create_account(options)
    u.save!
    u.account
  end
end
