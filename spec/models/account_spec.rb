# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

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
  # Authentication
  #

protected
  def create_account(options = {})
    u = User.create(:name => 'quire', :display_name => 'quire')
    u.create_account(options)
    u.account.identity_url = "http://example.com/me"
    u.save!
    u.account
  end
end
