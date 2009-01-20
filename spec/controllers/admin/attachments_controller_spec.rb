require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::AttachmentsController do
  fixtures :users, :notes

  before do
    controller.stub!(:current_user).and_return(@user = users(:quentin))
    controller.stub!(:current_note).and_return(@note = notes(:our_note))
    controller.stub!(:require_admin).and_return(true)
  end

  def mock_note(stubs={})
    @mock_note ||= mock_model(Note, stubs)
  end

  def mock_attachment(stubs={})
    @mock_attachment ||= mock_model(Attachment, stubs)
  end

end
