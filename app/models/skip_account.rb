class SkipAccount < ActiveRecord::Base
  belongs_to :user, :dependent=>:destroy
  validates_presence_of :user, :skip_uid

  class << self
    def skip_uid(identity_url)
      uri = URI(identity_url)
      # TODO SKIPのURLだと判断する基準を決める
      # return unless [uri.host, uri.port] == [URI(SKIP_URI).host, URI(SKIP_URI).port]
      uri.path.scan(%r!/user/([A-Za-z0-9]+)!).flatten.shift
    end
  end
end
